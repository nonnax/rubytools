#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2021-12-05 16:42:57 +0800
# println.rb
# outputs <n> lines of <file> from <line number>
# default: n==0
# rationale: it plays well with rg and ag for --vimgrep viewing files like filename:n:n
#
# $ println.rb file.txt:8 10
#
arg, rows = ARGV

rows = rows.nil? ? 0 : rows.to_i

f, line, = arg.split(/:/, 3)
line = line.to_i - 1
lines = File.readlines(f)

puts lines[line..line + rows].join
