#!/usr/bin/env ruby
# frozen_string_literal: true
# narrate.rb 
# 	narrates a file or a piped stream 
# 	uses espeak or festival
# 
# Id$ nonnax 2021-10-05 14:44:14 +0800
require 'console'
require 'string_ext'

# maxy=`tput cols`.to_i
# maxx=`tput lines`.to_i
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
	puts "~%d/%d. (%d)." % [i+1, para_size, paragraph_chunk.size]
	puts
	cont.each do |para|
		para.sentences.each do |s|
			puts s.lstrip.gsub(/\s{2,}/,' ')
		end
		puts
	end
	# puts paragraph_chunk
	puts 
end
