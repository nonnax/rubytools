#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2021-12-10 00:38:03 +0800
require 'rubytools/editor'
require 'optparse'

@options = {}
OptionParser.new do |opt|
  opt.banner = <<~___
    ged is a git repo aware editor.
    note: auto commits with a timestamp
  ___
end.parse!(into: @options)

def edit_and_commit(f)
  res = File.read(f)
  res = yield(res)
  File.write(f, res)
  IO.popen("git add #{f}", &:read)
  message="update: #{f}"
  IO.popen("git commit -m '#{message}'", &:read)
  puts IO.popen('git log --oneline', &:read)
rescue StandardError => e
  puts e
end

f = ARGV.first

edit_and_commit(f) do |text|
  IO.editor(text)
end
