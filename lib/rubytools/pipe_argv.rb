#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2021-12-12 22:48:44 +0800

def PIPE_ARGV
  key = ARGV.shift
  return key if key
  key = ARGF.gets
end
