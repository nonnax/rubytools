#!/usr/bin/env ruby
# Id$ nonnax 2022-05-23 15:26:39 +0800
require 'sqlite3'
# require 'json'

class HashDBM
  include Enumerable
  attr :db, :table

  def initialize(name='store.sqlite3', table:'store', &block)
    @db = SQLite3::Database.new(name)
    @db.results_as_hash
    @table = table
    find_or_create
    if block
      instance_eval(&block)
      @db.close
    end
  end

  def transaction(&block)
    # use a transaction for bulk-writes

    @transaction=true
    @db.transaction
    instance_exec(self, &block)
    @db.commit
  rescue Exception=>e
    @db.rollback
    puts e
  ensure
    @transaction=false
  end

  def [](k)
    @db.execute("SELECT value FROM #{table} WHERE key = ? LIMIT 1", k.to_s)
    .then{ |h| Marshal.load(h.first.first) if h.first }
  end

  def []=(k,v)
    raise "to be used inside transaction" unless @transaction
    @db.execute("INSERT OR REPLACE INTO #{table} (key, value) VALUES ( ?, ? )", k.to_s, Marshal.dump(v))
  end

  def each(&block)
    keys.each{|k| block.call(k, self[k])}
  end

  def keys
    sql = "SELECT key FROM #{table}"
    @db.execute(sql).flatten
  end

  def at(*keylist)
    # select all.
    # optionally filtering using `keylist` of string keys
    load=Marshal.method(:load)
    sql = "SELECT value FROM #{table}"
    sql << " WHERE key IN (#{Array(keylist).flatten.uniq.map(&:inspect).join(',')})" unless keylist.empty?
    sql = sql.tr( %("), %(') )   #"
    @db.execute(sql).flatten.map(&load)
  end

  def values
    load=Marshal.method(:load)
    @db.execute("SELECT value FROM #{table}").flatten.map(&load)
  end

  def key?(k)
    keys.include?(k.to_s)
  end

  def size
    keys.size
  end

  def merge!(h)
    transaction do
      h.each{ |k, v| self[k] = v }
    end
  end

  def values_at(*keys)
    select_values(include: keys)
  end

  private
  def find_or_create
     sql=<<~___
     CREATE TABLE IF NOT EXISTS #{table} (
       key BLOB PRIMARY KEY,
       value BLOB NOT NULL
      );
      ___
     @db.execute sql
  end

end

HDBM=HashDBM
