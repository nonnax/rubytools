#!/usr/bin/env mruby
# frozen_string_literal: true

# Id$ nonnax 2021-08-22 20:38:32 +0800
# require 'rubytools/d_array_bars'
require 'df/df_ext'
using DFExt

module DFPlotExt
  refine Array do
    def plot_df
      # plot an OHLC dataframe
      DFAsciiPlot.plot_df(self) do |b, r|
        yield([b, r])
      end
    end
    def plot_bars(**params)
      DFAsciiPlot.plot_bars(self, **params)
    end

    def fill(start, stop, char='x')
      stop=stop.clamp(0..self.size)
      (start...stop).each do |i|
        self[i] = char
      end
      self
    end
  end

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

using DFPlotExt

module DFAsciiPlot
  #
  # Unix-compatible Terminal OHLC data plotter
  # uses ANSI box drawing chars
  #

  module_function

  DENSITY_SIGNS = ['#', '░', '▒', '▓', '█'].freeze
  # BOX_HORIZ = '─'.freeze
  BOX_HORIZ = '-'
  # BOX_HORIZ_VERT = '┼'.freeze
  BOX_HORIZ_VERT = '┼'
  # BOX_HORIZ_VERT = '|'.freeze

  BAR_XLIMIT = 50
  @x_axis_limit = nil

  class << self
    attr_accessor :x_axis_limit
  end

  def candlestick(_name, open, high, low, close, min = 0, max = 100)
    #
    # plot an OHLC row as candlestick pattern
    # row format == [:row_1, o, h, l, c, min, max]
    #
    @x_axis_limit ||= BAR_XLIMIT
    bar = ' ' * @x_axis_limit

    up_down = (close <=> open)
    # normalize to zero x-axis
    open, low, high, close, min, max = [open, low, high, close, min, max].map(&:to_f).map{ |e| e - min.to_f }

    # normalize to percentage
    open, high, low, close = [open, high, low, close].map { |e| (e / max) * @x_axis_limit }.map(&:to_i) # .map(&:floor)

    len = (high - low)
    bar[low...(low + len)] = BOX_HORIZ * len
    start, stop = [open, close].minmax
    len = (stop - start)
    case len
    when 0
      start = [start - 1, 0].max
      bar[start] = BOX_HORIZ_VERT
    else
      bar[start...(start + len)] = DENSITY_SIGNS[-1] * len
    end
    up_down.negative? ? bar.magenta : bar.cyan
  end

  def openclose(_name, open, close, min = 0, max = 100, **params)
    #
    # plot an OHLC row as candlestick pattern
    # row format == [:row_1, o, h, l, c, min, max]
    #
    @x_axis_limit = params.fetch(:scale, 100/5)
    bar = [' '] * @x_axis_limit

    up_down = (close <=> open)
    # normalize to zero x-axis
    open, close, min, max = [open, close, min, max].map(&:to_f).map{ |e| e - min.to_f }
    # normalize to percentage
    open, close = [open, close].map { |e| (e / max) * @x_axis_limit }.map(&:to_i) # .map(&:floor)

    start, stop = [open, close].minmax
    len = (stop - start).abs

    bar.fill(start, (start + len), DENSITY_SIGNS[-1])

    if [start,stop].uniq.size==1
      start = [start - 1, 0].max
      bar[start]=BOX_HORIZ_VERT
    end

    up_down.negative? ? bar.map(&:magenta) : bar.map(&:cyan)
  end

  def plot_df(data)
    #
    # plots an OHLC dataframe
    # dataframe=[[:row_1, o, h, l, c], ...[:row_n, o, h, l, c]]
    #
    min, max = data.map { |r| r.values_at(1..-1) }.flatten.minmax
    data.each do |row|
      row_h = %i[title open high low close].zip(row).to_h
      yield([DFAsciiPlot.candlestick(*row, min, max), row_h])
    end
  end

  def plot_bar_map(data, **params,  &block)
    #
    # plots an OC dataframe
    # dataframe=[[:row_1, o, c], ...[:row_n, o, c]]
    #
    min, max = data.map { |r| r.values_at(1..-1) }.flatten.minmax
    data.map do |row|
      DFAsciiPlot.openclose(*row, min, max, **params)
      .tap{|arr| block.call(arr) if block}
    end
  end

  def plot_bars_header(bars, data, **params)
    min, max = data.dup.map(&:last).minmax
    rjust_width=params.fetch(:rjust, max.to_i.to_s.size+3)
    rjust=->x{
      ("%0.2f" % x).send(:rjust, rjust_width)
    }
    Array
    .new(bars.transpose.size-1){'-'}
    .tap{|header|
      header[-1]=rjust[max]
      header[header.size/2]=rjust[(max+min)/2]
      header[0]=rjust[min]
    }
  end

  def plot_bars(data, **params)
    Marshal.load(Marshal.dump(data))
    bars = DFAsciiPlot.plot_bar_map(data.dup, **params)

    header = plot_bars_header(bars, data, **params)

    bars
    .tap{|br| br.prepend(header)}
    .map(&:reverse)
    .to_table
  end
end


if __FILE__ == $PROGRAM_NAME
  DFAsciiPlot.x_axis_limit = 30

  data = []
  20.times do
    min = 170
    max = 245
    @min = min
    @max = max
    o = rand(min..max)
    l = max + rand(5)
    h = min + rand(10)
    c = rand(min..max)
    l, h = [o, l, h, c].minmax
    c = [c, h].min
    data << [:first20, o, h, l, c]
  end

  20.times do
    min = 70
    max = 180
    @min = min
    @max = max
    o = rand(min..max)
    l = max + rand(50)
    h = rand(min..min + 10)
    c = rand(min..max)
    l, h = [o, l, h, c].minmax
    c = [c, h].min
    data << [:next20, o, h, l, c]
  end

  30.times do
    min = 10
    max = 70
    @min = min
    @max = max
    o = rand(min..max)
    l = max + rand(5)
    h = min + rand(10)
    c = rand(min..max)
    l, h = [o, l, h, c].minmax
    c = [c, h].min
    data << [Time.now.to_s, o, h, l, c]
  end

  DFAsciiPlot.plot_df(data) do |bar, r|
    puts [bar, r[:title]].join(' ')
  end

  DFAsciiPlot.x_axis_limit = 100

  puts '-' * 100

  # require 'string_bars'
  using DFPlotExt

  # array plot
  string_bars = []

  data.plot_df  do |b, r|
    suff = r[:close] < r[:open] ? '-' : ' '
    string_bars << "title#{b.uncolor.gsub(/-/, '|')}#{suff}"
    puts [b, r[:title]].join("\t")
  end

  require 'df/df_ext'

  # data=[]
  # 40.times do
    # min = -10
    # max = 20
    # @min = min
    # @max = max
    # o = rand(min..max)
    # l = max + rand(5)
    # h = min + rand(10)
    # c = rand(min..max)
    # l, h = [o, l, h, c].minmax
    # c = [c, h].min
    # data << [Time.now.to_s, o, c]
  # end

  # re-format for OC plot
  # [
  #   [String, Number, Number]...
  # ]
  data=data.map.with_index{|r, i| r.values_at(i, -4, -1)}


  p 'DFAsciiPlot.plot_bars(data.dup)'
  puts DFAsciiPlot.plot_bars(data.dup)

  puts data.dup.plot_bars
  # puts DArrayBars.new(string_bars).to_hbars(delimeter: ' ')

end
