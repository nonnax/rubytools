#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2021-09-27 01:40:36 +0800
require 'rubytools'
require 'array_csv'
require 'array_table'
require 'ansi_color'
require 'numeric_ext'

def view_as_table(s)
  data=CSV.parse(s, converters: :numeric)
  data
    .to_table(delimeter: '  ')
    .each_with_index{|r, i| puts i.even? ? r : r.magenta}
end

view_as_table($stdin.read)
