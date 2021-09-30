#!/usr/bin/env ruby
# concut.rb
#   an ffmpeg tool to cut and merge sections from a single input
# -*- nonnax  -*- : 2021-09-30 01:37:01 +0800 
require 'fzf'
require 'arraycsv'

p inf=Dir["*.*"].fzf.first

exit unless inf
sane_name=inf.gsub(/[^\w\d\.]/, '_')

CUTLIST_FILE="cut-#{sane_name}.csv"
cuttimes_df=ArrayCSV.new(CUTLIST_FILE)
cuttimes_df.empty? && cuttimes_df<<%w[00:00:00.000 00:00:01.000]
cuttimes=cuttimes_df.dataframe

cmd=[]
prefix=[]

cmd<<"ffmpeg"

cuttimes.each_with_index do |(ss, to), i|
  cmd<<"-ss #{ss} -to #{to} -i '#{inf}'"
  prefix<<"[%d:v][%d:a]" % [i, i]
end
prefilter=prefix.join(' ')

cmd<<"-filter_complex '#{prefilter}concat=n=#{cuttimes.size}:v=1:a=1[out]'"
cmd<<"-map '[out]'"
cmd<<"'out-#{sane_name}'"
p cmd = cmd * ' '
IO.popen(cmd, &:read)
