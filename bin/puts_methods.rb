#!/usr/bin/env ruby
require 'methods_view'

class_puts, is_class_methods=ARGV
klass=eval("#{class_puts}") 

if is_class_methods
	klass.puts_methods(send: :methods) if (klass.kind_of?(Class) or klass.kind_of?(Module))
else
	klass.puts_methods if (klass.kind_of?(Class) or klass.kind_of?(Module))
end
