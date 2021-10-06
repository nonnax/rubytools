#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2021-10-06 19:09:52 +0800
require 'fzf'

# 0 = 90CounterCLockwise and Vertical Flip (default)
# 1 = 90Clockwise
# 2 = 90CounterClockwise
# 3 = 90Clockwise and Vertical Flip
# 
# or
# 
# ffmpeg -i in.mp4 -vf 'rotate=-PI/2' out.mp4

trans_type = ARGV.first&.to_i || 2

inf = Dir['*.*'].fzf.first

cmd = []
cmd << 'ffmpeg'
cmd << "-i #{inf}"
# cmd<<"-vf 'transpose=#{trans_type}'"
cmd << "-vf 'rotate=-PI/2'"
cmd << '-crf 22' # -qscale 0"
cmd << "out-#{inf}"

p cmd * ' '

IO.popen(cmd.join(' '), &:read)
