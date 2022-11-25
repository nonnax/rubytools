#!/usr/bin/env ruby
# Id$ nonnax 2022-11-23 12:45:54
require 'file/file_importer'

module Texticle
  module_function
   def self.render(f, io_handler: File.method(:read), &block)
    io_handler.(f)
    .then{|s| FileImporter.parse(s) } #.tap{|s| puts s}
    .then{|s| Texticle.parse(s, &block) }
    .then{|s| s.join }
   end
end
