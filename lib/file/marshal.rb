#!/usr/bin/env ruby
# Id$ nonnax 2022-11-17 10:00:17
require_relative 'serializer'

class MarshalFile<Serializer
  def read
    Marshal.load(File.read(@path))
  end
  def write(obj)
    File.write @path, Marshal.dump(obj)
  end
end

