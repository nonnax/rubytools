#!/usr/bin/env ruby
# frozen_string_literal: true

require 'rubytools'
require 'methods_view'
require 'ansi_color'
require 'fzf'

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

  m = IO.popen("ri --format=markdown #{selected} | bat -p -l markdown --color=always | fzf", &:read)
  obj_method = [selected, m.strip].join('.')
  IO.popen("ri --format=markdown #{obj_method} | bat -p -l markdown --color=always | fzf", &:read)
end
