#!/usr/bin/env ruby
# Id$ nonnax 2022-11-17 10:00:17
require_relative 'serializer'
require 'json'

class JSONFile < Serializer
  def read(**opts)
    JSON.parse(File.read(@path), **opts)
  end
  def write(obj)
    File.write @path, JSON.pretty_generate(obj)
  end
end

