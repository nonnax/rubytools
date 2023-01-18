#!/usr/bin/env ruby

module NumericExt
  refine String do
    # def is_number?
    # !/\A[+-]?\d+(\.\d+)?\z/.match?(self).nil?
    # end

    def human(n = 2, &block)
      numeric? ? to_f.to_human(n) : block&.call
    end

    alias_method :to_human, :human

    def numeric?
      true if Float(self)
    rescue StandardError
      false
    end
    alias_method :is_number?, :numeric?

    def base32_to_i
      to_i(32)
    end

    def as_number(re = /[+-.,\d]+/)
      tr(',', '').scan(re) # .first
    end

    def to_number(&block)
      if numeric?
        match?(/\./) ? Float(self) : Integer(self)
      else
        block&.call
      end
    end

    alias_method :to_digits, :as_number

    def with_commas
      i, _, d = partition('.')
      d = '00' if d.empty?
      int = i.reverse.split(//).each_slice(3).to_a.map(&:join).join('_').reverse
      [int, d].join('.')
    end
    alias_method :with_comma, :with_commas
  end

  refine Float do
    def human(dec = 2)
      return if infinite?

      to_str(dec).with_commas
    end
    alias_method :to_human, :human

    def to_str(digit = 2)
      format("%0.#{digit}f", self)
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
    times
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
    def numeric?
      self
    end

    # Convert time intervals to seconds
    def milliseconds
      self / 1000.0
    end

    def seconds
      self
    end
    alias_method :second, :seconds

    def minutes
      self * 60
    end
    alias_method :minute, :minutes

    def hours
      self * 60 * 60
    end
    alias_method :hour, :hours

    def days
      self * 60 * 60 * 24
    end
    alias_method :day, :days

    def weeks
      self * 60 * 60 * 24 * 7
    end
    alias_method :week, :weeks

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
