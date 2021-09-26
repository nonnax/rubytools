#!/usr/bin/env ruby
# frozen_string_literal: true

require 'array_table'

module MethodsTable
  def puts_methods(**opts, &block)
    data = []
    selector = opts[:send] || :instance_methods
    width = opts[:width] || 38

    send(selector)
      .sort
      .each_slice(width) do |slice|
      data << slice
              .map(&:to_s)
              .map
              .with_index { |e, i| block_given? ? block.call(e, i) : e }
    end

    return if data.empty?

		# pad with nils for transpose 
    data = data.tap { |d| 
    		d[-1] += [nil] * (d.first.size - d.last.size) 
    	}.transpose
    puts data.to_table(ljust: (0..data.first.size), delimeter: '   ')
  end
end

class Class
  include MethodsTable
end

module Kernel
  include MethodsTable
end

class Symbol
  def ri
    puts IO.popen("ri -T #{self}", &:read)
  end
end

class String
  def ri
    puts IO.popen("ri -T #{self}", &:read)
  end
end
