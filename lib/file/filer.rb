#!/usr/bin/env ruby
# Id$ nonnax 2022-11-17 10:00:17
# delegator class for file object supporting read and write intefaces
require_relative 'marshal'
require_relative 'yaml'
require_relative 'textfile'
require_relative 'msgpack'
require 'forwardable'

class Filer
  extend Forwardable
  def_delegators :@strategy, :read, :write, :path

  def initialize(strategy)
    @strategy=strategy
  end

  def self.read(strategy, &block)
    new(strategy).read(&block)
  end

  def self.write(strategy, obj)
    new(strategy).write(obj)
  end

end

