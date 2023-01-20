#!/usr/bin/env ruby
# Id$ nonnax 2023-01-20 18:24:51
require 'math/math_ext'
require 'rubytools/console_ext'
using MathExt

class Progressbar
 attr :min, :max, :x, :y
 def initialize(max:100, x:0, y:0)
  @value=value
  @max=max
  @bar='#'
  @x, @y = x, y
 end

 def update(i, size:100, &block)
   size = size.clamp(5, size)
   frac = ((i.succ/@max.to_f)*100).human.to_f
   bar = @bar * (frac * (size/100.0))
   fmt_str = "%03d | %s"
   text = format(fmt_str,  frac, bar).ljust(size+(fmt_str.size-2)) + '|'
   if block
      block.call(text, frac)
   else
      printxy x, y, text
   end
 end
end
