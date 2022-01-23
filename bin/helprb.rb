#!/usr/bin/env ruby
# frozen_string_literal: true

require 'rubytools'
require 'methods_view'
require 'ansi_color'
require 'fzf'

# class Object
  # def method_info
    # test_type = respond_to?(:instance_methods) ? :instance_methods : :methods
    # send(test_type)
      # .sort
      # .fzf_preview("ri --format=markdown {} | bat -l markdown --color=always")
      # .first
  # end
# end

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

  m=IO.popen("ri --format=markdown #{selected.to_s} | bat -p -l markdown --color=always | fzf", &:read)
  obj_method=[selected,m.strip].join('.')
  IO.popen("ri --format=markdown #{obj_method} | bat -p -l markdown --color=always | fzf", &:read)
  
end
