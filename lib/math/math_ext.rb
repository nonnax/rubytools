#!/usr/bin/env ruby
# Id$ nonnax 2022-12-09 10:58:57
require 'rubytools/numeric_ext'
require 'rubytools/array_ext'

module MathExt
 include NumericExt
 include ArrayExt

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
  alias average mean

  def delta_change
   self
   .each_cons(2)
   .map(&:to_delta)
   .flatten
  end

  def to_delta
   # precondition: a two-element array or the opposite elements of an array
   # return:  Numeric
   [self.first_last].map{|a, b| a.delta_change(b) }.pop
  end

  def moving_average(n)
   self
   .reverse
   .each_cons(n).map{|cons| cons.mean }
   .reverse
  end

  def rate_change(n)
   self
   .each_cons(n)
   .map(&:to_delta)
  end

  def to_percent
   self.map{|x| x * 100}
  end

  def to_series
   self.each_cons(2).map.with_index{|e, i| [i, e].flatten }
  end

  def first_last
    [self.first, self.last]
  end

  def meansert
    (self<<mean).flatten.uniq.sort
  end

  def means(n=1)
    return self.map(&:to_f).uniq.sort if n<1
    arr=each_cons(2).map(&:meansert).flatten.sort.uniq
    arr.meansert.means(n-1)
  end

 end

end
