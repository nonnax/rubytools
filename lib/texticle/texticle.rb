#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2022-11-23 10:12:46
require_relative 'texticle_render'

module Texticle
  module_function

  PATTERN = /
   (\{\{)(.*?)\}\}     | # capture a multi-line ruby block {{ <ruby code> }}
   (?<!\{)(\{)(.*?)\}    # capture {variable} value as a string
  /mx

  def parse(template, **h)
    f = h.fetch('report', 'report')
    _context = h.fetch('context', self)
    a = []

    h.each do |k, v|
      a<<format("%s='%s';", k, v)
    end

    terms =
      template
        .split(PATTERN)
        .compact
        .map(&:chomp)

    while term = terms.shift
      a << case term
           when '{{' then format('%s', "#{terms.shift};")
           when '{' then "__arr<<(#{terms.shift}).to_s;"
           else "__arr<<#{term.dump};"
           end
    end
    s = "Proc.new{|params| __arr=[]; #{a.join("\n")} }"

    _context
      .instance_eval(s, f, -1)
      .call(h)
      .join
  end
end
