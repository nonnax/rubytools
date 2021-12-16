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
    Time.send(method, dest.year, dest.month, dest.day, dest.hour, dest.min,
              dest.sec, usec)
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
  def to_days
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
  alias to_day to_days
end

class Time
  include TimeToWords
end

class Date
  include TimeToWords
end

class DateTime
  include TimeToWords
  def default_date_format
    strftime('%Y-%m-%d')
  end
end

#
## Helper methods for working with time units other than seconds
# class Numeric
# # Convert time intervals to seconds
# def milliseconds; self/1000.0; end
# def seconds; self; end
# def minutes; self*60; end
# def hours; self*60*60; end
# def days; self*60*60*24; end
# def weeks; self*60*60*24*7; end
#
# # Convert seconds to other intervals
# def to_milliseconds; self*1000; end
# def to_seconds; self; end
# def to_minutes; self/60.0; end
# def to_hours; self/(60*60.0); end
# def to_days; self/(60*60*24.0); end
# def to_weeks; self/(60*60*24*7.0); end
# end

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
		t=Time.now
		[t.yday, t.hour, t.min, t.sec].sum
	end
	def self.now_to_s
		t=Time.now
		"%04d%02d%02d%02d" % [t.yday, t.hour, t.min, t.sec]
	end
end

module Strftime
  def as_time
    Time.now.strftime(self)
  end
end

String.include(Strftime)
