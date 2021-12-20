#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2021-10-08 15:40:15 +0800
require 'rubytools'
require 'array_table'
require 'array_csv'
require 'editor'
require 'fzf'
require 'string_ext'
require 'fileutils'

f = ARGV.first

exit unless f.text_file? && f.match(/csv$/i)

FileUtils.cp(f, "#{Time.now.yday}_#{File.basename(f)}")

f ||= Dir['*.csv'].fzf(cmd: 'fzf --preview="csview {}"').first

# break unless f
exit unless f

data = ArrayCSV.new(f)
text =
  data
  .dataframe
  .safe_transpose
  .safe_transpose
  .to_table(delimeter: ', ')

res =
  [].tap do |arr|
    IO.editor(text)
      .lines
      .map do |r|
        csv =
          r
          .gsub(/\s,/, ',')
          .gsub(/\s{2,}/, ' ')
          .lstrip
        arr << CSV.parse(csv).flatten
      end
  end

ArrayCSV.open(f, 'w') do |csv|
  csv.dataframe = res
end
