#!/usr/bin/env ruby
# Id$ nonnax 2022-11-17 10:00:17
require_relative 'serializer'

class TextFile < Serializer
  def read(&block)
  # run default block on exception

    File.read(@path)
  rescue => e
    puts e
    block.call(self)
  end
  def write(obj)
    File.write @path, obj
  end
end

