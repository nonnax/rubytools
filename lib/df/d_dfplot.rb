#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2023-03-11 16:33:15 +0800
# require 'df/df_ext'

class DDFPlot
    class BBars
      BBARS=['⠠', '⠄','⠤']

      def self.to_bar(n)
        x, q = n.abs.divmod(2)
        bars = []
        bars << BBARS[2]*x

        bars = n.negative? ? bars.push(BBARS[1]) : bars.prepend(BBARS[0])
        bars.join
      end

    end

   def initialize(df_h)
     @df=df_h
   end

   def to_error_bars(scale: 50, char: '|')
     keys = @df.map(&:keys).flatten
     keys_width = keys.map(&:to_s).map(&:size).max
     values = @df.map(&:values).flatten
     scaled_v = DF(values.map(&:abs)).to_percent_ratios.map{|e| e*100.0}
     data=keys.zip(values.zip(scaled_v)).to_h

     maps=[]
     data.each_with_object(maps) do |h, a|
       k, v, sv = h.to_a.flatten
       idx = v.negative? ? 0 : -1

       # bars=char*(sv.abs*scale)
       t = Array.new(3){""}
       t[idx]=BBars.to_bar(sv)
       t[1]=['',k.to_s.rjust(keys_width)].join(" ")
       t[0]=t[0].rjust(scale/2)
       t[-1]=t[-1].dup.prepend(" ")
       a<<t.join
     end

     maps.join("\n")
   end
end
