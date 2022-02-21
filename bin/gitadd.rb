#!/usr/bin/env ruby

# Id$ nonnax 2021-10-19 14:15:56 +0800
require 'rubytools/fzf'

cmd = "git status 2>1 | ruby -ne 'puts $_.chomp.split(/:\s+/).last if $_.match(/fied\:/)'"
modified = IO.popen(cmd, &:read)

files = modified.lines(chomp: true).sort.reverse.fzf(cmd: %(fzf -m --preview='git status'))

cmd = 'git add ' << files.join(' ')

IO.popen(cmd, &:read)
