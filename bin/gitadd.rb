#!/usr/bin/env ruby
# Id$ nonnax 2021-10-19 14:15:56 +0800
require 'rubytools/fzf'

files=Dir["**/*.*"].sort.reverse.fzf(cmd: %{fzf -m --preview='git status'})

cmd="git add "<<files.join(' ')

IO.popen(cmd, &:read)
