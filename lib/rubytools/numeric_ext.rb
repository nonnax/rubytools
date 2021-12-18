#!/usr/bin/env ruby
# frozen_string_literal: true

class String
  def is_number?
    # obj = obj.to_s unless obj.is_a? String
    !/\A[+-]?\d+(\.\d+)?\z/.match(self).nil?
  end
  def base32_to_i
    to_i(32)
  end
end

class Integer
  def to_base32(padding: 6)
    to_s(32).rjust(padding, '0')
  end
end

class Object
  def is_number?
    to_s.is_number?
  end
end

#
## Helper methods for working with time units other than seconds
module NumericHelper

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

module NumericFormatter
# special

  def commify
    return if infinite?

    n = abs

    u, d = (format('%.2f', n.to_f)).split('.')
    arr = u.to_s.reverse.split('')
    arr = arr.each_slice(3).map(&:join).join('_').reverse

    arr << '.' << d unless is_a?(Integer)
    arr = "-#{arr}" if negative?
    arr
  end
  def to_s
    self.commify
  end
end

Numeric.include(NumericHelper)
Float.prepend(NumericFormatter)
Integer.prepend(NumericFormatter)


