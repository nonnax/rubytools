#!/usr/bin/env ruby
# Id$ nonnax 2022-11-17 10:00:17
require_relative 'serializer'

class TextFile < Serializer
  def read(**opts)
    File.read(@path, **opts)
  end
  def write(obj)
    File.write @path, obj
  end
end

