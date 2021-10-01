#!/usr/bin/env ruby
require 'fzf'

inf=Dir["*.*"].fzf.first
# -vf 'scale=trunc(iw/4)*2:trunc(ih/4)*2' -c:v libx265 -crf 20-28  #1.5 size 
# -vf 'scale=trunc(iw/4)*3:trunc(ih/4)*3' -c:v libx265 -crf 20-28  #1.75 size
cmd=[]
cmd<<"ffmpeg" 
cmd<<"-i '#{inf}' "
cmd<<"-vf 'scale=trunc(iw/4)*2:trunc(ih/4)*2'"
# cmd<<"-c:v libx265 -crf 28 " # more compression
cmd<<"-c:v libx265 -crf 24 "
cmd<<"'out-#{inf}'"
IO.popen(cmd.join(' '), &:read)
