#!/usr/bin/env ruby
# frozen_string_literal: true

require 'delegate'
# require 'rubytools/array_table'
require 'df/df_ext'
require 'rubytools/ansi_color'
using DFExt

# Renders strings vertically
# a trailing dash (-) renders a red bar
# a trailing dash (-) renders a red bar
class DArrayRotate < SimpleDelegator
  def rotate_left(separator: '', &block)
    def expand_rows(&block)
      max_width = map(&:size).max
      map!  do |r|
        sign = r.split(//).last
        marked=sign&.match?('-')
        r=r.chomp('-') if marked
        l = r.reverse.ljust(max_width).split(//) # split each element
        l = block[l, marked]
      end
    end

    dup
    .expand_rows{|bar, marked| marked ? bar.map(&:light_magenta) : bar.map(&:light_white) }
    .map(&:reverse)
    .to_table(separator:)
  end
  alias rotate_strings rotate_left
end


if __FILE__ == $PROGRAM_NAME
  data = []

  data << 'RONALDEVAN'
  data << 'RON'
  data << 'RONALD-'  # a trailing dash (-) renders a red bar
  data << 'NALD-DUDE' # non-trailing dashes (-) are ignored
  puts '# data'
  puts data

  puts "# 2.times{ |i| puts DArrayRotate.new(data).rotate_left(separator: ' '*i)  }"
  2.times{ |i| puts DArrayRotate.new(data).rotate_left(separator: ' '*i )  }

  puts '# puts data.rotate_left'
  puts DArrayRotate.new(data).rotate_left

end
