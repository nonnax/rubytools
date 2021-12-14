#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2021-12-10 00:38:03 +0800
require 'rubytools'
require 'editor'
require 'string_ext'
require 'optparse'

exit unless ARGV.first.text_file?

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

  f_base=File.basename(f)

  message="update: #{f_base}"
  IO.popen("git add #{f_base} && git commit -m '#{message}'", &:read)
  
rescue StandardError => e
  puts e
ensure 
  puts IO.popen("git log --oneline | head ", &:read)
end

f = ARGV.first

edit_and_commit(f) do |text|
  IO.editor(text)
end
