#!/usr/bin/env ruby
# Id$ nonnax 2022-12-09 10:58:57
require 'rubytools/numeric_ext'

module MathExt
 include NumericExt
 refine Numeric do
  def delta_change(to)
   Float(to)/self-1
  end
  alias delta delta_change
  def to_percent
    self * 100
  end
 end

 refine Enumerable do
  def mean
   self.sum/self.size.to_f
  end

  def delta_change
   self.each_cons(2).map{|a, b| a.delta_change(b) }
  end

  def moving_average(n)
   self
   .reverse
   .each_cons(n).map{|cons| cons.mean }
   .reverse
  end

  def to_percent
   self.map{|x| x * 100}
  end

 end

end
