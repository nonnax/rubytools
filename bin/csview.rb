#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2021-09-27 01:40:36 +0800
require 'rubytools'
require 'array_csv'
require 'array_table'
require 'numeric_ext'
require 'ansi_color'
require 'tempfile'

path=ARGV.first

unless path
  fs=Tempfile.new
  fs.puts $stdin.read
  fs.rewind
  path=fs.path
end

def view_as_table(f)
  data = ArrayCSV.parse(f)

  data
    .to_table(delimeter: '  ')
    .each_with_index{|r, i| puts i.even? ? r : r.magenta}  
end

view_as_table(path)
