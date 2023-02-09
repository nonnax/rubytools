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

  def self.load(strategy, &block)
    new(strategy).then{|o|
      [o, o.read{ o.write block&.call(o)}]
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
  def self.read_csv(f, **opts)
    read(CSVFile.new(f), **opts)
  end
  def self.write_csv(f, df)
    write(CSVFile.new(f), df)
  end
end

