#!/usr/bin/env ruby
# frozen_string_literal: true
require 'rubytools'
require 'numeric_ext'
require 'string_ext'
require 'hash_ext'
require 'file_ext'
require 'time_and_date_ext'

class NilClass
  # +nil+ is blank:
  #
  # nil.blank? # => true
  #
  def blank?
    true
  end
end

class FalseClass
  # +false+ is blank:
  #
  # false.blank? # => true
  #
  def blank?
    true
  end
end

class TrueClass
  # +true+ is not blank:
  #
  # true.blank? # => false
  #
  def blank?
    false
  end
end

class Array
  # An array is blank if it's empty:
  #
  # [].blank? # => true
  # [1,2,3].blank? # => false
  #
  alias blank? empty?
end

class Hash
  # A hash is blank if it's empty:
  #
  # {}.blank? # => true
  # {:key => 'value'}.blank? # => false
  #
  alias blank? empty?
end

class String
  # A string is blank if it's empty or contains whitespaces only:
  #
  # "".blank? # => true
  # " ".blank? # => true
  # " something here ".blank? # => false
  #
  def blank?
    self !~ /\S/
  end
end

class Numeric #:nodoc:
  # No number is blank:
  #
  # 1.blank? # => false
  # 0.blank? # => false
  #
  def blank?
    false
  end
end
