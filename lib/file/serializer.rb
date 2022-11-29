#!/usr/bin/env ruby
# Id$ nonnax 2022-11-17 10:00:17
class Serializer
  attr :path
  def initialize(f)
    @path=f
  end
  def read(&block)
    #stub
  end
  def write(obj)
    # stub
  end
  def self.read(f, &block)
    new(f).read(&block)
  end
  def self.write(f, obj)
    new(f).write(obj)
  end
end

