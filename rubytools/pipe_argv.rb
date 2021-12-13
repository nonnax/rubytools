#!/usr/bin/env ruby
# Id$ nonnax 2021-12-12 22:48:44 +0800

def PIPE_ARGV()
  key=ARGV.first
  return key if key
  key=$stdin.gets unless $stdin.tty? && $stdin.closed?
end
