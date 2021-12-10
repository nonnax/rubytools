#!/usr/bin/env ruby
# Id$ nonnax 2021-12-08 18:35:10 +0800
# tabulatedd.rb
# prints a list as table columns 
# reads a -- (double-dash) delimeted list from STDIN
# only the last double-dash within a line is selected
require 'rubytools/array_table'
require 'optparse'

OptionParser.new do |opt|
  opt.banner=<<~___ 
  tabulatedd, pretty-formats a double-dash (--) separated list. 
  ___
end.parse!

lines=$stdin.read.split("\n")

puts lines.map{|e| 
     if e.match(/--/)
      e.reverse.split(/\s*--\s*/,2).map(&:reverse)
     else
      ["", e]
     end
  }
  .map(&:reverse)
  .map{|pair| pair.map(&:strip)}
  .to_table(ljust: [0], delimeter: ' : ')
