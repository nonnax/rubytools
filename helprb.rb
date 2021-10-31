#!/usr/bin/env ruby
# frozen_string_literal: true

require 'array_table'
require 'methods_view'
require 'ansi_color'
require 'fzf'

# class Array
  # def fzf_preview(preview = 'ri {}')
    # IO.popen("fzf -m --ansi --preview='#{preview}'", 'w+') do |io|
      # io.puts to_a.join("\n")
      # io.read.split
    # end
  # end
# end

class Class
  def method_info
    instance_methods
      .sort
      .fzf_preview("ri --format=markdown #{name}.{} | bat -l markdown --color=always", cmd: 'fzf --ansi')
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
             .fzf_preview('puts_methods.rb {}', cmd: 'fzf --ansi')
             .first

  break unless selected

  eval(selected.to_s).method_info # (:instance_methods)
end
