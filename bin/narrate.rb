#!/usr/bin/env ruby
# frozen_string_literal: true
# narrate.rb 
# 	narrates a file or a piped stream 
# 	uses espeak or festival
# 
# Id$ nonnax 2021-10-05 14:44:14 +0800
require 'rubytools/console_ext'
require 'rubytools/string_ext'

maxx, maxy = IO::Screen.winsize

def ARGS
  # intercepts input params either as arguments or piped str
  #
  content =
    if !$stdin.tty? && !$stdin.closed?
      $stdin.read
    elsif !ARGV.empty?
      ARGV
    end
  yield content
end

content, start = 
ARGS() do |arg|
    case arg
    when Array
      f, start = arg
      [File.read(f), start.to_i]
    when String
      [arg, 0]
    else
      exit
    end
  end

CHUNK_SIZE=1
para_size=content.paragraphs.each_slice(CHUNK_SIZE).to_a.size

content.paragraphs.each_slice(CHUNK_SIZE).each_with_index do |cont, i|
  puts paragraph_chunk=cont.join("\n\n")
  puts "%d/%d. (%d)." % [i+1, para_size, paragraph_chunk.size]
  puts
  p mp3=Dir["*.mp3"].grep( Regexp.new("-%02d" % [i+1]))
  puts "play '#{mp3.first}' &>/dev/null"
  IO.popen("mpv --loop-playlist=no --loop-file=no '#{mp3.first}' &>/dev/null"){|io| io.read}
  IO.popen('espeak --stdin &>/dev/null', 'w') { |io| io.puts paragraph_chunk }
  sleep 3
  puts
end

