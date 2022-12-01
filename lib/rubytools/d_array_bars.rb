#!/usr/bin/env ruby
# frozen_string_literal: true

require 'delegate'
require 'rubytools/array_table'
require 'rubytools/ansi_color'

class DArrayBars < SimpleDelegator
  def to_vbars(delimiter: ' . ', &block)
    def expand_rows(&block)
      max_width = map(&:size).max
      map!  do |r|
        sign = r.split(//).last
        marked=sign.match('-')
        r=r.chomp('-') if marked
        l = r.ljust(max_width).split(//) # split each element
        l = block[l, marked]
      end
    end

    dup.expand_rows{|bar, marked| marked ? bar.map(&:red) : bar.map(&:cyan) }
    .map(&:reverse)
    .transpose
    .to_table(delimiter:)
  end
end
if __FILE__ == $PROGRAM_NAME
  data = []

  data << 'RONALDEVAN'
  data << 'RON'
  data << 'RONALD-'  # a trailing dash (-) renders a red bar
  data << 'NALD-DUDE' # non-trailing dashes (-) are ignored
  puts '# data'
  puts data

  puts "# 2.times{ |i| puts DArrayBars.new(data).to_vbars(delimiter: ' '*i)  }"
  2.times{ |i| puts DArrayBars.new(data).to_vbars(delimiter: ' '*i)  }

  puts '# puts data.to_hbars'
  puts DArrayBars.new(data).to_vbars

end
