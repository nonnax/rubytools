#!/usr/bin/env ruby
# Id$ nonnax 2022-11-17 10:00:17
require_relative 'serializer'
require 'json'

class JSONFile < Serializer
  def read
  # run default block on exception

    JSON.parse(File.read(@path), symbolize_names:true)
  rescue
    nil
  end
  def write(obj)
    File.write @path, obj.to_json
  end
end

