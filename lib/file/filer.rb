#!/usr/bin/env ruby
# Id$ nonnax 2022-11-17 10:00:17
# delegator class for file object supporting read and write intefaces
require_relative 'marshal'
require_relative 'yaml'
require_relative 'json'
require_relative 'csv'
require_relative 'textfile'
require_relative 'msgpack'
require_relative 'msgpack'
require 'forwardable'
require 'file/file_ext'

class Filer
  extend Forwardable
  def_delegators :@strategy, :path

  def initialize(strategy)
    @strategy=strategy
  end

  def read(**opts, &block)
  # run default block on exception
    @strategy.read(**opts)
  rescue=>e
    puts e
    block&.call
  end

  def write(obj)
    obj.tap{|o| @strategy.write(o) }
  end

  # self.load
  # reads or creates a new file
  #
  # returns a pair [filer_object, container_obj]
  def self.load(strategy, **opts, &block)
    new(strategy).then{|o|
      [o, o.read(**opts){ block&.call.tap{|default| o.write default } }]
    }
  end

  def self.read(strategy, **opts, &block)
    new(strategy).read(**opts, &block)
  end

  def self.write(strategy, obj)
    new(strategy).write(obj)
  end

end

class Filer
  def self.load_marshal(f, **opts, &)
    load(MarshalFile.new(f), **opts, &)
  end
  def self.write_marshal(f, df)
    write(MarshalFile.new(f), df)
  end
  def self.load_csv(f, **opts, &)
    load(CSVFile.new(f), **opts, &)
  end
  def self.write_csv(f, df)
    write(CSVFile.new(f), df)
  end

  def self.load_json(f, **opts, &)
    load(JSONFile.new(f), **opts, &)
  end
  def self.write_json(f, df)
    write(JSONFile.new(f), df)
  end
  class << self
    alias csv_load load_csv
    alias csv_write write_csv

    alias json_load load_json
    alias json_write write_json

    alias marshal_load load_marshal
    alias marshal_write write_marshal
  end
end

