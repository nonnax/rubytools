#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2021-10-08 15:40:15 +0800
require 'arraycsv'
require 'array_table'
require 'editor'
require 'fzf'
require 'fileutils'

f = ARGV.first

exit if f && !f.match(/csv$/i)

FileUtils.cp(f, "#{Time.now.yday}_#{File.basename(f)}")

  f ||= Dir['*.csv'].fzf(cmd: 'fzf --preview="csview {}"').first

  # break unless f
  exit unless f

  data = ArrayCSV.new(f)

  res = IO.editor(data.dataframe.safe_transpose.safe_transpose.to_table(delimeter: "\t"))
          .lines
          .map { |r| r.tr("\t", ',').gsub(/\s/, '') }

  File.open(f, 'w') { |io| io.puts(res) }

  f = nil
