#!/usr/bin/env ruby
# Id$ nonnax 2023-03-31 19:32:14 +0800
# Shell
# shell templater
# usage: shell template_file, key value key2 value2
# uses Texticle and FileImporter
# use @import 'partial'
# note: any shell command can also be used in the template
# multiple shell commands are separated by `&&` as usual
# useful template commands:
# basename(fname), ts(timestamp) for timestamp math, in addition to all public ruby methods
#

require 'texticle/texticle'
require 'file/file_importer'
require 'time/time_ext'

class Shell
  attr :cmd

  def initialize(f, **params)
    first = File.readlines(f)
    first = first.reject{|l| l.match?(/^#/)}.join("\n")
    @template = FileImporter.parse(first).to_s

    @params = params
  end

  def render
    @cmd=Texticle.parse(@template, **@params).gsub(/\n+/, '  ')
  end

  def run
    puts IO.popen(render, &:read)
  end

end

module Kernel
  def basename(f, ext='.*')
    File.basename(f, ext)
  end
  alias :ts :TStamp
end

