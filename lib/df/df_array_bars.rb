#!/usr/bin/env ruby
# Id$ nonnax 2023-03-11 16:33:15 +0800
require 'df/df_ext'

module ArrayBarsExt
  refine Enumerable do
   def to_error_bars(scale: 10)
     scaled = DF(self).to_percent_ratios.map(&:abs).map{|e| e*scale}
     data = self.zip(DF(scaled)).to_h

     maps=[]
     data.each_with_object(maps) do |(k, v), a|
       idx = k.negative? ? 0 : -1
       bars='#'*(v*0.75)
       t = Array.new(3){""}
       t[idx]=bars
       t[1]=k.to_s.rjust(5)
       t[0]=t[0].rjust(scale)
       t[-1]=t[-1].prepend(" ")
       a<<t.join
     end

     maps.join("\n")
   end
  end
end

DFExt.include(ArrayBarsExt)
