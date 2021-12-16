#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2021-09-27 01:40:36 +0800
require 'rubytools'
require 'array_csv'
require 'array_table'
require 'numeric_ext'
require 'fzf'


csvstr = $stdin.read

def view_as_table(s)
  data = CSV.parse(s)

  normalized_df = data.map do |r|
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

view_as_table(csvstr)
