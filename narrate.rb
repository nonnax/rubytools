#!/usr/bin/env ruby
# frozen_string_literal: true
# narrate.rb 
# 	narrates a file or a piped stream 
# 	uses espeak or festival
# 
# Id$ nonnax 2021-10-05 14:44:14 +0800
require 'console'

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

module SentenceScanner
  RE_SENTENCE = /[^.?!]+[^)](?:[.?!)])/.freeze

  def sentences
    gsub!(/\n/, ' ')
    keys = %w[“ ” ‘ ’]
    vals = %w[" " ' ']
    to_tr = keys.zip(vals).to_h
    to_tr.each { |k, v| tr!(k, v) }

    scan(RE_SENTENCE).map # {|e| yield e}
  end
end

String.include(SentenceScanner)

content.sentences.to_a[start..-1].each_slice(3) do |s|
  s.each do |e|
    puts e.strip.center(maxy)
  end

  # IO.popen("festival --tts", 'w'){|io| io.puts s.join}
  IO.popen('espeak --stdin &>/dev/null', 'w') { |io| io.puts s.join }
end
