#!/usr/bin/env ruby
# Id$ nonnax 2022-11-17 10:00:17
# delegator class for file object supporting read and write intefaces
require_relative 'marshal'
require_relative 'msgpack'
require_relative 'yaml'
require_relative 'textfile'

# sort-of an error handler for nil results
class Object
  def or(&block)
    block.call(self)
  end
end
class NilClass
  def or(&block)
    block.call
  end
end

class Filer
  def initialize(strategy)
    @strategy=strategy
  end
  def read(&block)
  # run default block on exception
    @strategy.read(&block)
  rescue
    nil
  end
  def write(obj)
    @strategy.write(obj)
  end
  def path
    @strategy.path
  end
  def self.read(strategy, &block)
    new(strategy).read(&block)
  end
  def self.write(strategy, obj)
    new(strategy).write(obj)
  end

end

