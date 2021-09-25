#!/usr/bin/env ruby
# frozen_string_literal: true

require 'array_table'
require 'methods_view'

class Array
  def fzf_preview(preview = 'ri {}')
    IO.popen("fzf -m --preview='#{preview}'", 'w+') do |io|
      io.puts to_a.join("\n")
      io.read.split
    end
  end
end

class Class
  def method_info
    instance_methods
      .sort
      .fzf_preview("ri #{name}.{}")
      .first
  end
end
loop do
  data = []

  selected = Object
             .constants
             .sort
             .map(&:to_s)
             .map(&:yellow)
             .fzf_preview('puts_methods.rb {}')
             .first

  break unless selected

  eval(selected.to_s).method_info # (:instance_methods)
end
