#!/usr/bin/env ruby
# frozen_string_literal: true

# require 'text-table'
require_relative '../lib/rubytools/numeric_ext'
require_relative '../lib/rubytools/arraycsv'
require_relative '../lib/rubytools/time_and_date_ext'
require_relative '../lib/rubytools/array_table'
require_relative '../lib/rubytools/ansi_color'

files = ARGV

def view_as_table(f)
  data = ArrayCSV.new(f)

  human_df = data.dataframe.map do |r|
    r.map do |e|
      if e.to_s.is_number? 
        e.to_f.commify
      elsif (e.to_s.is_date? and not e.to_s.is_number?)
        e.to_s.to_date.to_days
      elsif e.nil?
        e="-"
      else
        e
      end
    end
  end

  i=true
  table = human_df.to_table( rjust: (0..human_df.first.size), delimeter: ' '*3 ) do |r|
    row = i ? r.join(' ') : r.join(' ').light_magenta
    row = r.join(' ').yellow if (r.last.strip.is_number? && r.last.strip.to_f > 0 ) 
    i = !i
    row 
  end

  puts table
end

files.each do |f|
  view_as_table(f)
end
