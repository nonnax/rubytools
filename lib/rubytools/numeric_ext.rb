#!/usr/bin/env ruby
# frozen_string_literal: true

module NumericExt
  refine String do
    def is_number?
      !/\A[+-]?\d+(\.\d+)?\z/.match?(self).nil?
    end

    def numeric?
     true if Float(str) rescue false
    end

    def base32_to_i
      to_i(32)
    end

    def as_number
      self.scan(/[+-.\d]+/).first
    end

    def with_commas
      i, _, d = partition('.')
      d='00' if d.empty?
      int=i.reverse.split(//).each_slice(3).to_a.map(&:join).join('_').reverse
      [int, d].join('.')
    end
    alias with_comma with_commas

  end

  refine Integer do
    def to_base32(padding: 6)
      to_s(32).rjust(padding, '0')
    end
  end

  refine Object do
    def is_number?
      to_s.is_number?
    end

    def in?(enum)
      enum.include?(self) if enum.respond_to?(:include?)
    end

  end
end

module CollectionPager
  def pages_of(n)
    self
    .times
    .each_slice(n)
    .map.with_index do |pgs, pg|
      [pg, pgs]
    end
    .to_h
  end
end


# pages=50.pages_of(6)
# p pages[0]
# p pages[6]

#
## Helper methods for working with time units other than seconds
module NumericExt
  refine Numeric do
    # Convert time intervals to seconds
    def milliseconds
      self / 1000.0
    end

    def seconds
      self
    end
    alias second seconds

    def minutes
      self * 60
    end
    alias minute minutes

    def hours
      self * 60 * 60
    end
    alias hour hours

    def days
      self * 60 * 60 * 24
    end
    alias day days

    def weeks
      self * 60 * 60 * 24 * 7
    end
    alias week weeks

    # Convert seconds to other intervals
    def to_milliseconds
      self * 1000
    end

    def to_seconds
      self
    end

    def to_minutes
      self / 60.0
    end

    def to_hours
      self / (60 * 60.0)
    end

    def to_days
      self / (60 * 60 * 24.0)
    end

    def to_weeks
      self / (60 * 60 * 24 * 7.0)
    end
  end
end


using NumericExt

module FloatExt
  refine Float do
    def human
      return if infinite?
      to_s.with_commas
    end


    def to_s(digit=nil)
      fmt_str = digit ? "%0.#{digit}f"  : "%0.2f"
      fmt_str % self
    end
  end
end

module NumericExt
  include FloatExt
end

Integer.include(CollectionPager)
