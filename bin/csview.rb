#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2021-09-27 01:40:36 +0800
require 'rubytools'
require 'arraycsv'
require 'array_table'
require 'numeric_ext'
require 'fzf'
require 'pipe_argv'
require 'tempfile'

path=ARGV.first

unless path
  fs=Tempfile.new
  fs.puts $stdin.read
  fs.rewind
  path=fs.path
end

def view_as_table(f)
  data = ArrayCSV.new(f)

  normalized_df = data.dataframe.map do |r|
    r.map do |e|
      if e.to_s.is_number?
        e.to_f.commify
      else
        e
      end
    end
  end

  table = normalized_df.to_table(delimeter: '  ')

  puts table
end

view_as_table(path)
