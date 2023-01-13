#!/usr/bin/env ruby
# Id$ nonnax 2023-01-13 10:52:55
require 'rubytools/core_ext'

module Scrapemathics
 include CoreExt
 class String
  def scan_to_f(re=/[\d\.,]+/)
    scan(re).map{|n| n.tr ',', ''}.map(&:to_f)
  end
 end

 class Array
   def pair_describe
     first_last.then{ |pair|
       pair_delta = pair.then{|d| [[d, d.to_delta.to_percent.human.to_f]].to_h}
       pair_mean_delta = pair.means.each_cons(2).map{|d| [[d, d.to_delta.to_percent.human.to_f]].to_h}
       {pair_delta:, pair_mean_delta: }
     }
   end
 end
end
