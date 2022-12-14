#!/usr/bin/env ruby
# Id$ nonnax 2022-12-13 23:46:04
require 'rubytools/ansi_color'

module ArrayPlotExt
  refine Array do
    def fill(start, stop, char='x')
      stop=stop.clamp(0..self.size)
      (start...stop).each do |i|
        self[i] = char
      end
      self
    end
  end
end

module ObjectPlotExt
  refine Object do
    def deep_dup
      Marshal.load(Marshal.dump(self))
    end
  end
end


module StringPlotExt
  refine String do
    # color helper for drawing candlestick patterns on a Unix/Linux terminal
    def set_color(color_code)
      "\e[#{color_code}m#{self}\e[0m"
    end

    def color_codes
      {
        red: 31,
        light_red: 91,
        green: 32,
        light_green: 92,
        yellow: 33,
        blue: 34,
        magenta: 35,
        light_magenta: 95,
        pink: 35,
        light_pink: 95,
        cyan: 36,
        light_cyan: 96
      }
    end

    def uncolor
      gsub(/\e\[\d+m/, '')
    end

    ''.color_codes.each do |k, v|
      define_method(k) { set_color(v) }
    end
  end
end

module AsciiPlotExt
  include ObjectPlotExt
  include ArrayPlotExt
  include StringPlotExt
end
