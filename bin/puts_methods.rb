#!/usr/bin/env ruby
# frozen_string_literal: true

require 'rubytools/methods_view'

class_puts, is_class_methods = ARGV
klass = eval(class_puts.to_s)

if is_class_methods
  klass.puts_methods(send: :methods) if klass.is_a?(Class) || klass.is_a?(Module)
elsif klass.is_a?(Class) || klass.is_a?(Module)
  klass.puts_methods
end
