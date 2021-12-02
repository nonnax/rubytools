#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2021-12-01 22:59:36 +0800
require 'fileutils'
require 'rubytools/fzf'
sortday = {}
Dir['*.*'].fzf(cmd: 'ls *.* | fzf -m').each do |f|
  date = File.open(f).mtime.strftime('%Y%m%d')
  (sortday[date] ||= []) << f
  date
end

sortday.each do |d, fs|
  FileUtils.mkdir(d) unless Dir.exist?(d)
  FileUtils.mv(fs, d)
  puts "%w[#{fs.join(' ')}] --> #{d}/"
end
