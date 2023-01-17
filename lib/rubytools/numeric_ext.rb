#!/usr/bin/env ruby
# frozen_string_literal: true

module NumericExt
  refine String do
    # def is_number?
      # !/\A[+-]?\d+(\.\d+)?\z/.match?(self).nil?
    # end
    def human(n=2, &block)
      numeric? ? to_f.to_human(n) : block&.call
    end

    def numeric?
     true if Float(self) rescue false
    end
    alias is_number? numeric?

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

  refine Float do
    def human(dec=2)
      return if infinite?
      to_str(dec).with_commas
    end
    alias to_human human

    def to_str(digit=nil)
      fmt_str = digit ? "%0.#{digit}f"  : "%0.2f"
      fmt_str % self
    end
  end

  refine Integer do
    def to_base32(padding: 6)
      to_s(32).rjust(padding, '0')
    end
  end

  refine Object do
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

Integer.include(CollectionPager)
