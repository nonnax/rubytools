#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2021-10-08 15:40:15 +0800
require 'rubytools/arraycsv'
require 'rubytools/array_table'
require 'rubytools/editor'
require 'rubytools/fzf'
require 'fileutils'

f = ARGV.first

exit if f && !f.match(/csv$/i)

FileUtils.cp(f, "#{Time.now.yday}_#{File.basename(f)}")

f ||= Dir['*.csv'].fzf(cmd: 'fzf --preview="csview {}"').first

# break unless f
exit unless f

data = ArrayCSV.new(f)
text=data
    .dataframe
    .safe_transpose
    .safe_transpose
    .to_table(delimeter: "\t")

res = IO.editor(text)
        .lines
        .map { |r| r.tr("\t", ',') }

File.open(f, 'w') { |io| io.puts(res) }
