# frozen_string_literal: true

class String
	def is_number?
	  # obj = obj.to_s unless obj.is_a? String
	  not /\A[+-]?\d+(\.[\d]+)?\z/.match(self).nil?
	end
end

require 'ansi_color'
class String
	def color_number
		if self.strip.is_number? 
			self.to_f.negative? ? self.red : self.yellow
		else
			self.white
		end
	end
end

# class Object
	# def is_number?
	  # obj = obj.to_s unless obj.is_a? String
	  # not /\A[+-]?\d+(\.[\d]+)?\z/.match(obj).nil?
	# end
# end

class Numeric

  def rates(f = 0.05, **params, &block)
    repeat = params[:size] || 3
    d = []
    (0..repeat).each do |i|
      d << self * (i * f + 1)
      d << self / (i * f + 1)
    end
    d.sort.uniq.map(&block)
  end

  def minutes
    self * 60
  end
  alias minute minutes

  def hours
    minutes * 60
  end
  alias hour hours

  def days
    hours * 24
  end
  alias day days

  def commify
  	n=self.abs
    u, d = (format('%.2f', n.to_f)).split('.')
    arr = u.to_s.reverse.split('')
    arr = arr.each_slice(3).map(&:join).join('_').reverse

    arr << '.' << d unless is_a?(Integer)
    arr='-'+arr if self.negative?
    arr
  end
end

#
## Helper methods for working with time units other than seconds
class Numeric
  # Convert time intervals to seconds
  def milliseconds
    self / 1000.0
  end

  def seconds
    self
  end

  def minutes
    self * 60
  end

  def hours
    self * 60 * 60
  end

  def days
    self * 60 * 60 * 24
  end

  def weeks
    self * 60 * 60 * 24 * 7
  end

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
