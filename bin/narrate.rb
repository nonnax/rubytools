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

start-=1
start=[0, start].max

CHUNK_SIZE=3
para_size=content.paragraphs.each_slice(CHUNK_SIZE).to_a.size
paragraphs=content.paragraphs.each_slice(CHUNK_SIZE).to_a[start..-1]

paragraphs.each_with_index do |cont, i|
  puts paragraph_chunk=cont.join("\n\n")
  puts
  mp3=Dir["*.mp3"].grep( Regexp.new("-%02d" % [start+i+1])).first
  puts "%d/%d. (%d) %s" % [start+i+1, para_size, paragraph_chunk.size, mp3]
  
  # IO.popen("mpv -vo null --loop-playlist=no --loop-file=no --no-resume-playback '#{mp3.first}'"){|io| io.read}
  IO.popen("mpv --loop-playlist=no --loop-file=no --no-resume-playback '#{mp3}' &>/dev/null"){|io| io.read}
  # IO.popen('espeak --stdin &>/dev/null', 'w') { |io| io.puts paragraph_chunk }
  sleep 0.5
  puts
end

