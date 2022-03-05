#!/usr/bin/env ruby

# Id$ nonnax 2021-10-19 14:15:56 +0800
require 'rubytools/fzf'

q,_ = ARGV
re=Regexp.new(q)

type=%w[add rm].zip(%w[modified deleted]).to_h

k=type.keys.grep(re).first

cmd = "git status 2>1 | ruby -ne 'puts $_.chomp.split(/:\s+/).last if $_.match?(/#{type[k]}/)'"
res = IO.popen(cmd, &:read)

files = res.lines(chomp: true).sort.reverse.fzf(cmd: %(fzf -m --preview='git status'))

exit if files.empty?

p cmd = "git #{k} "  << files.join(' ')

IO.popen(cmd, &:read)
