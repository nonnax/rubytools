#!/usr/bin/env ruby
# frozen_string_literal: true
# narrate.rb 
# 	narrates a file or a piped stream 
# 	uses espeak or festival
# 
# Id$ nonnax 2021-10-05 14:44:14 +0800
require 'console'
require 'string_ext'

maxx, maxy = ANSIScreen.winsize

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

content, start = ARGS() do |arg|
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

CHUNK_SIZE=4
para_size=content.paragraphs.each_slice(CHUNK_SIZE).to_a.size

content.paragraphs.each_slice(CHUNK_SIZE).each_with_index do |cont, i|
	paragraph_chunk=cont.join("\n\n")
	puts "%d/%d. (%d)." % [i+1, para_size, paragraph_chunk.size]
	puts
	cont.each do |para|
		para.sentences.each do |s|
			puts s.center(maxy)
		end
		puts
	end
	# puts paragraph_chunk
	# p mp3=Dir["*.mp3"].grep( Regexp.new("-%02d" % [i+1]))
	# IO.popen("play '#{mp3.first}' &>/dev/null"){|io| io.read}
	IO.popen('espeak --stdin &>/dev/null', 'w') { |io| io.puts paragraph_chunk }
	sleep 3
	puts
end

