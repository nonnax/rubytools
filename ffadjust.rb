#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2021-10-06 19:52:32 +0800
# ffmpeg -i clip.mp4 -itsoffset 0.150 -i clip.mp4 -vcodec copy -acodec copy -map 0:0 -map 1:1 output.mp4
require 'fzf'

delay = ARGV.first.to_i
inf = Dir['*.*'].fzf.first

cmd = []
cmd << 'ffmpeg'
cmd << "-i #{inf}"
cmd << "-itsoffset #{delay}"
cmd << "-i #{inf}"
cmd << '-codec copy'
cmd << '-map 0:0 -map 1:1' # 0:video 1:audio
cmd << "out-#{inf}"

p cmd_str = cmd * ' '
IO.popen(cmd_str, &:read)
