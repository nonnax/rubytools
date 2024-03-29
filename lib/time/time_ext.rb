#!/usr/bin/env ruby
# frozen_string_literal: true

require 'date'
require 'chronic'

class String
  def to_date
    Chronic.parse(self)
  end
  alias to_time to_date

  def is_date?
    !Chronic.parse(self).nil?
  end
  alias is_time? is_date?
end

class Integer
  def to_time
    Time.at(self)
  end
end

class Time
  def to_datetime
    # Convert seconds + microseconds into a fractional number of seconds
    seconds = sec + Rational(usec, 10**6)

    # Convert a UTC offset measured in minutes to one measured in a
    # fraction of a day.
    offset = Rational(utc_offset, 60 * 60 * 24)
    DateTime.new(year, month, day, hour, min, seconds, offset)
  end

  def default_date_format
    strftime('%Y-%m-%d')
  end

  def self.this_min
    now.deconstruct_keys(nil)  => {year:, month:, day:, hour:, min:}
    sday =  [year, month, day] * '-'
    stime = [hour, min] * ':'
    parse([sday, stime].join(' '))
  end

  # returns age in seconds
  def age
    (Time.now-self)*1000
  end
end

# Similar adjustments to Date will let you convert DateTime to Time .
class Date
  def to_gm_time
    to_time(new_offset, :gm)
  end

  def to_local_time
    to_time(new_offset(DateTime.now.offset - offset), :local)
  end

  def default_date_format
    strftime('%Y-%m-%d')
  end

  private

  def to_time(dest, method)
    # Convert a fraction of a day to a number of microseconds
    usec = (dest.sec_fraction * 60 * 60 * 24 * (10**6)).to_i
    Time.send(
      method,
      dest.year,
      dest.month,
      dest.day,
      dest.hour,
      dest.min,
      dest.sec,
      usec
    )
  end
end

module TimeHuman
  def human(n=2, &block)
    to_s.to_human(n, &block)
  end
end

module TimeToWords
  def to_words
    timestamp = self
    minutes = ((Time.now - timestamp).abs / 60).round
    return nil if minutes.negative?

    case minutes
    when 0               then 'about a minute ago'
    when 0..4            then 'about 5 minutes ago'
    when 5..14           then 'about 15 minutes ago'
    when 15..29          then 'about 30 minutes ago'
    when 30..59          then 'over 30 minutes ago'
    when 60..119         then 'over 1 hour ago'
    when 120..239        then 'over 2 hours ago'
    when 240..479        then 'over 4 hours ago'
    else
      if minutes.abs < 182 * 1440
        # timestamp.strftime('%d-%b %a %I:%M %p')
      else
        # timestamp.strftime('%d-%b-%Y %a %I:%M %p')
      end
      timestamp.strftime('%a, %Y-%b-%e')
    end
  end

  def to_date
    (DateTime.now - self).to_i * -1
  end

  # (date)
  def to_human_days
    date = begin
      send(:to_date)
    rescue StandardError
      self
    end
    days = (date - Date.today).to_i

    return 'today'     if (days >= 0) && (days < 1)
    return 'tomorrow'  if (days >= 1) && (days < 2)
    return 'yesterday' if (days >= -1) && days.negative?

    return "in #{days} days"      if (days.abs < 60) && days.positive?
    return "#{days.abs} days ago" if (days.abs < 60) && days.negative?

    return date.strftime('%a, %Y-%b-%e') if days.abs < 182

    date.strftime('%a, %Y-%b-%e')
  end

  def to_days
    date = begin
      send(:to_date)
    rescue StandardError
      self
    end
    (date - Date.today).to_i
  end

  alias to_day to_days
end

class Time
  include TimeToWords
  include TimeHuman
end

class Date
  include TimeToWords
  include TimeHuman
end

class DateTime
  include TimeToWords
  include TimeHuman
  def default_date_format
    strftime('%Y-%m-%d')
  end
end

#
## Helper methods for working with time units other than seconds
class Numeric
  # Convert time intervals to seconds
  def milliseconds; self/1000.0; end
  def seconds; self; end
  def minutes; self*60; end
  def hours; self*60*60; end
  def days; self*60*60*24; end
  def weeks; self*60*60*24*7; end

  alias_method :second, :seconds
  alias_method :minute, :minutes
  alias_method :hour, :hours
  alias_method :day, :days
  alias_method :week, :weeks

  # Convert seconds to other intervals
  def to_milliseconds; self*1000; end
  def to_seconds; self; end
  def to_minutes; self/60.0; end
  def to_hours; self/(60*60.0); end
  def to_days; self/(60*60*24.0); end
  def to_weeks; self/(60*60*24*7.0); end
end

# expires = now + 10.days     # 10 days from now
# expires - now               # => 864000.0 seconds
# (expires - now).to_hours    # => 240.0 hours

class String
  # duplicate spec in string_ext.rb
  def to_msec
    h, m, s, ms = match(/(\d{2}):(\d{2}):(\d{2}).(\d{2,3})/)&.captures
    t = ((h.to_i * 60 + m.to_i) * 60 + s.to_i) * 1000 + ms.to_i			# 0-99 ms
  end
  alias to_ms to_msec
  def sanitize
    gsub(/[^\w\d.]/, '_')
  end
end

class Numeric
  def to_ts
    s, ms = divmod(1000)
    m, s = s.divmod(60)
    h, m = m.divmod(60)
    format('%02d:%02d:%02d.%03d', h, m, s, ms)
  end
  alias to_timestamp to_ts

  def sec_to_ms
    self * 1000
  end
end

class Time
  def to_ms
    (to_f * 1000.0).to_i
  end
  alias to_msec to_ms
  def to_ts
    to_ms.to_ts
  end

  def self.now_sum
    t = Time.now
    [t.yday, t.hour, t.min, t.sec].sum
  end

  def self.now_to_s
    t = Time.now
    format('%04d%02d%02d%02d', t.yday, t.hour, t.min, t.sec)
  end
end

module Strftime
  def as_strftime
    Time.now.strftime(self)
  end
end

String.include(Strftime)

module TimeSlice
  def timeslice(repeat)
    max_ts = to_ms

    repeat &&= repeat.to_i
    slice_size = max_ts / repeat

    xtimes =
      repeat
      .times
      .map { |x| x * slice_size }
    xtimes << max_ts

    xtimes.each_cons(2).map do |x|
      x.map(&:to_ts)
    end
  end
end

String.include(TimeSlice)

module TimestampExt
  refine String do
    def plus(ts)
      (to_ms + ts.to_ms).to_ts # (fmt: "%02d:%02d:%02d.%02d")
    end

    def minus(ts)
      (to_ms - ts.to_ms).to_ts # (fmt: "%02d:%02d:%02d.%02d")
    end
  end
end

module Timestamp
  using TimestampExt

  module_function
  def self.ts(ts)
    ts.to_ms
  end
  def self.add(a, b, &block)
    res=a.to_ms+b.to_ms
    block&.call(res)
    res.to_ts
  end
  def self.diff(a, b, &block)
    a, b = [a.to_ms,b.to_ms].sort.reverse
    res=a - b
    block&.call(res)
    res.to_ts
  end
end

# TStamp
# Timestamp calculator
class TStamp
  using TimestampExt
  attr :msec
  def initialize(ts)
    @msec = ts.to_ms
  end
  def +(ts)
    ts = TStamp.new(ts) unless ts.is_a?(TStamp)

    (msec+ts.msec).to_ts
  end

  def -(ts)
    ts = TStamp.new(ts) unless ts.is_a?(TStamp)

    ms, ts = [msec, ts.msec].sort.reverse
    (ms-ts).to_ts
  end
end

module KernelExt
  def TStamp(ts)
    TStamp.new(ts)
  end
end

Kernel.include(KernelExt)
