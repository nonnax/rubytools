#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2022-12-09 10:58:57
require 'rubytools/numeric_ext'
require 'rubytools/array_ext'
require 'rubytools/time_ext'
# require 'math'

using NumericExt

module MathExt
  include NumericExt
  include ArrayExt

  refine Object do
    def display
      Kernel.puts self
    end

    def prepend_to(arr)
      arr.prepend(self)
    end

    def append_to(arr)
      arr.push(self)
    end
  end

  refine Numeric do
    def delta_change(to)
      Float(to) / self - 1
    end
    alias_method :delta, :delta_change

    def delta_changed(delta)
      self/(delta+1)
    end

    def percent_changed(percent)
      self/(percent/100.0+1)
    end

    def percent_origin_of(n)
      n.to_f/(self/100.0+1)
    end
    alias percentage_of percent_origin_of

    def percent_change(to)
      delta_change(Float(to)).to_percent.human.to_f
    end

    def to_percent
      self * 100
    end

    def diff(to)
      Float(to)-self
    end

    def human_auto
      format_big_small=->(n){ n=Float(n); n.between?(0, 1) ? n.human(7) : n.human}
      format_big_small[self]
    end

    def percent_ratio(to)
      (to_f/to.to_f)
    end

    def percent_of(n)
      # decimal percent/non-fractional, e.g. 5% of 100 == 5
      n=Float(n)
      n * (to_f / 100)
    end

    def percent_inc(n)
      n=Float(n)
      n + percent_of(n)
    end
    alias percent percent_inc
    alias percent_above percent_inc

    def percent_dec(n)
      n=Float(n)
      n - percent_of(n)
    end
    alias percent_below percent_dec

  end

  refine Object do
    def to_human_auto
      respond_to?(:human_auto) ? self.human_auto : self
    end
  end

  refine String do
    def human_auto
      self
    end
  end

  refine Time do
    def human_auto
      self
    end
  end

  refine Enumerable do
    def mean
      sum / size.to_f
    end
    alias_method :average, :mean

    def variance
      m = self.mean
      sum = self.inject(0){|accum, i| accum + (i - m) ** 2 }
      return sum / (self.size - 1).to_f
    end

    def stdev
      return Math.sqrt(self.variance)
    end
    alias sigma stdev

    def coefficient_of_variation
      (stdev/mean)*100
    end
    alias cv coefficient_of_variation

    def delta_change
      each_cons(2)
        .map(&:to_delta)
        .flatten
    end

    def to_delta
      to_change :delta_change
    end

    def to_percent_ratio
      to_change(:percent_ratio)&.to_percent
    end

    def to_percent_change
      to_change :percent_change
    end

    def to_diff
      to_change :diff
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
      (self << mean.round(9)).flatten.uniq.sort
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
