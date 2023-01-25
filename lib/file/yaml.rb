#!/usr/bin/env ruby
# Id$ nonnax 2022-11-17 10:00:17
require_relative 'serializer'
require 'yaml'

class YAMLFile < Serializer
  def read(**opts)
    YAML.load(File.read(@path), **opts)
  end
  def write(obj)
    File.write @path, obj.to_yaml
  end
end

