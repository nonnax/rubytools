#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2021-10-06 19:52:32 +0800

require 'fzf'

inf = Dir['*.*'].fzf.first
# -vf 'scale=trunc(iw/4)*2:trunc(ih/4)*2' -c:v libx265 -crf 20-28  #1.5 size
# -vf 'scale=trunc(iw/4)*3:trunc(ih/4)*3' -c:v libx265 -crf 20-28  #1.75 size
cmd = []
cmd << 'ffmpeg'
cmd << "-i '#{inf}' "
cmd << "-vf 'scale=trunc(iw/4)*2:trunc(ih/4)*2'"
# cmd<<"-vf 'scale=trunc(iw/4)*3:trunc(ih/4)*3'"
cmd << '-c:v libx265'
cmd << '-crf 22'
cmd << "'out-#{inf}'"

IO.popen(cmd.join(' '), &:read)
