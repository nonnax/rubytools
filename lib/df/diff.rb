#!/usr/bin/env ruby
# Id$ nonnax 2022-11-27 22:06:47
require 'rubytools/ansi_color'

class DF
  def update(df, cols: nil)
    return self unless df
    # widest df column determines the column size unless <cols> is defined

    @rows.clear
    @cols = cols if cols
    @cols = df.map(&:size).max unless @cols
    df.each {|row| self << row.map(&:to_s).map(&:cyan) }
    self
  end

  def diff(another, width:1, color: 'yellow', &block)
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
end
