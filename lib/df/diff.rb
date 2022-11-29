#!/usr/bin/env ruby
# Id$ nonnax 2022-11-27 22:06:47
require 'rubytools/ansi_color'

class DF

  def diff(another, **params, &block)
    width=params.fetch(:width, 1)
    color=params.fetch(:color, 'yellow')

    str_just=->x{ x.to_s.send(:rjust, width) }
    b = another.to_a
    v = to_a.map.with_index do |r, i|
      r.map.with_index do |v, j|
        bv = b[i][j]
        cond = block&.call(v, bv) || v != bv
        cond ? str_just[v].send(color) : str_just[v].cyan
      end
    end
    DF.new { v }
  end

  def to_s(**params, &block)
    width=params.fetch(:width, 1)
    color=params.fetch(:color, 'white')
    separator=params.fetch(:separator, ' ')
    str_just=->x{ x.to_s.send(:rjust, width).send(color) }
    @rows.map{|r| r.map(&str_just).join(separator)}.join("\n")
  end
end
