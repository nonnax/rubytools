#!/usr/bin/env ruby
# Id$ nonnax 2023-03-11 16:33:15 +0800
require 'df/df_ext'

class DDFPlot
   def initialize(df)
     @df=df
   end
   def to_error_bars(scale: 10, char: '#')
     scaled = DF(@df).to_percent_ratios.map(&:abs).map{|e| e*scale}
     data = @df.zip(DF(scaled)).to_h

     maps=[]
     data.each_with_object(maps) do |(k, v), a|
       idx = k.negative? ? 0 : -1
       bars=char*(v*0.75)
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
