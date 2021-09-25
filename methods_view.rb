#!/usr/bin/env ruby
require 'string_ext'
require 'array_table'
require 'ansi_color'


module MethodsTable
	def puts_methods(**opts)
		data=[]
		selector=opts[:send] || :instance_methods
		width=opts[:width] || 38

		self
			.send(selector)
			.sort
			.each_slice(width) do |g| 
				data<<g
							.map(&:to_s)
							.map
							.with_index{|e, i| i%2==0 ? e.magenta : e.cyan }		
			end

		return if data.empty?
		data=data.tap{|d| d[-1]+=[nil]*(d.first.size-d.last.size) }.transpose
		# puts self.name
		puts data.to_table(ljust: (0..data.first.size), delimeter: ' '*3)
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



