#!/usr/bin/env ruby
# Id$ nonnax 2022-11-17 10:00:17
class MarshalFile
  attr :path
  def initialize(f)
    @path=f
  end
  def read(&block)
  # run default block on exception

    Marshal.load(File.read(@path))
  rescue => e
    puts e
    block.call(self)
  end
  def write(obj)
    File.write @path, Marshal.dump(obj)
  end
  def self.read(f, &block)
    new(f).read(&block)
  end
  def self.write(f, obj)
    new(f).write(obj)
  end
end

