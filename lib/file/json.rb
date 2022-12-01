#!/usr/bin/env ruby
# Id$ nonnax 2022-11-17 10:00:17
require_relative 'serializer'
require 'json'

class JSONFile < Serializer
  def read
    JSON.parse(File.read(@path), symbolize_names:true)
  end
  def write(obj)
    File.write @path, JSON.pretty_generate(obj)
  end
end

