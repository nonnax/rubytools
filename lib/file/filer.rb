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

  def read(&block)
  # run default block on exception
    @strategy.read
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

  def self.read(strategy, &block)
    new(strategy).read(&block)
  end

  def self.write(strategy, obj)
    new(strategy).write(obj)
  end

end

