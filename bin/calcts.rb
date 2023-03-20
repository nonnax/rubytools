#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2021-10-10 21:37:14 +0800
require 'rubytools/core_ext'


class String
  def plus(ts)
    (to_ms + ts.to_ms).to_ts # (fmt: "%02d:%02d:%02d.%02d")
  end

  def minus(ts)
    (to_ms - ts.to_ms).to_ts # (fmt: "%02d:%02d:%02d.%02d")
  end

  def compute(ts)
    if ts[0] == '-'
      ts[0] == ''
      subt = true
    end
    subt.nil? ? plus(ts) : minus(ts)
  end
end



# s=n.compute(a)
# x, sec=s.split(/\./)
# sec="%02d" % [(sec.to_i/1000.to_f)*100]
# print s, "\t", [x, sec].join('.'), "\n"

ARGF.readlines(chomp:true).map{|l| l.split(/\t|,/)}.each do |n, a|
  puts [n, a, n.compute(a)].join("\t")
end
