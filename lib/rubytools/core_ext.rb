#!/usr/bin/env ruby
# frozen_string_literal: true

require 'rubytools'
require 'numeric_ext'
require 'string_ext'
require 'hash_ext'
require 'file/file_ext'
require 'time_and_date_ext'

module CoreExt
  refine NilClass do
    # +nil+ is blank:
    #
    # nil.blank? # => true
    #
    def blank?
      true
    end
  end

  refine FalseClass do
    # +false+ is blank:
    #
    # false.blank? # => true
    #
    def blank?
      true
    end
  end

  refine TrueClass do
    # +true+ is not blank:
    #
    # true.blank? # => false
    #
    def blank?
      false
    end
  end

  refine Array do
    # An array is blank if it's empty:
    #
    # [].blank? # => true
    # [1,2,3].blank? # => false
    #
    alias blank? empty?
  end

  refine Hash do
    # A hash is blank if it's empty:
    #
    # {}.blank? # => true
    # {:key => 'value'}.blank? # => false
    #
    alias blank? empty?
  end

  refine String do
    # A string is blank if it's empty or contains whitespaces only:
    #
    # "".blank? # => true
    # " ".blank? # => true
    # " something here ".blank? # => false
    #
    def blank?
      !self.match?(/\S/)
    end
  end

  refine Numeric do # :nodoc:
    # No number is blank:
    #
    # 1.blank? # => false
    # 0.blank? # => false
    #
    def blank?
      false
    end
  end

  refine Object do
    def into(arr)
      return unless arr.respond_to?(:<<)
      arr<<self
    end
  end

end
