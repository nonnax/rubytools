#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2021-09-27 01:40:36 +0800
require 'arraycsv'
require 'array_table'
require 'numeric_ext'
require 'fzf'

fs = ARGV

fs.first == '-fzf' && fs = Dir['*.*'].fzf

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

fs.each do |f|
  view_as_table(f)
end