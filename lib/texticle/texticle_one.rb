#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2022-11-23 10:12:46
require_relative 'texticle_render'

module Texticle
  module_function
  # for protection against code injection, no string string interpolation is allowed in templates!


  # capture a multi-line ruby block
  PATTERN = /(\{\{)(.*?)\}\}/mx

  def parse(template, f = 'report')
    terms = template.split(PATTERN).compact.map(&:chomp)
    a = []
    while term = terms.shift
      a << case term
           when '{{' then format('%s', "#{terms.shift};")
           else "__acc<<#{term.dump};"
           end
    end
    s = "Proc.new{ __acc=[]; #{a.join("\n")} }"
    instance_eval(s, f, -1).call
  end
end
