#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2022-12-09 10:58:57
require 'rubytools/numeric_ext'
require 'rubytools/array_ext'
using NumericExt

module MathExt
  include NumericExt
  include ArrayExt

  refine Object do
    def display
      Kernel.puts self
    end
  end

  refine Numeric do
    def delta_change(to)
      Float(to) / self - 1
    end
    alias_method :delta, :delta_change
    def to_percent
      self * 100
    end

    def percent_change(to)
      delta_change(to).to_percent.human.to_f
    end

    # def percent_up(pct, &block)
      # x = self * pct.to_f
      # block&.call(x)
      # self + x
    # end
#
    # def percent_down(pct, &block)
      # x = self * pct.to_f.abs
      # block&.call((self - x) - self)
      # (self - x).abs
    # end

    def percent_of(n)
      # decimal percent/non-fractional, e.g. 5% of 100 == 5
      n * (to_f / 100)
    end

    def percent_inc(n)
      n + percent_of(n)
    end
    alias percent percent_inc

    def percent_dec(n)
      n - percent_of(n)
    end
  end

  refine Enumerable do
    def mean
      sum / size.to_f
    end
    alias_method :average, :mean

    def delta_change
      each_cons(2)
        .map(&:to_delta)
        .flatten
    end

    def to_delta
      to_change :delta_change
    end

    def to_percent_change
      to_change :percent_change
    end

    def to_change(method_type = :delta_change)
      # precondition: a two-element array or the opposite elements of an array
      # return:  Numeric
      [first_last].map { |a, b| a.send(method_type, b) }.pop
    end

    def moving_average(n)
      reverse
        .each_cons(n).map(&:mean)
        .reverse
    end

    def rate_change(n)
      each_cons(n)
        .map(&:to_delta)
    end

    def to_percent
      map { |x| x * 100 }
    end

    def to_series
      each_cons(2).map.with_index { |e, i| [i, e].flatten }
    end

    def meansert
      (self << mean).flatten.uniq.sort
    end

    def means(n = 1)
      return map(&:to_f).uniq.sort if n < 1

      arr = each_cons(2).map(&:meansert).flatten.sort.uniq
      arr.meansert.means(n - 1)
    end

    def every(interval, at = :first)
      each_cons(interval).map(&at).flatten.map
    end

    def first_last
      [first, last]
    end

  end
end
