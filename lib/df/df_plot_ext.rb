#!/usr/bin/env mruby
# frozen_string_literal: true

# Id$ nonnax 2021-08-22 20:38:32 +0800
# require 'rubytools/d_array_bars'
# $LOAD_PATH<<'./lib'
require 'df/df_ext'
require 'rubytools/ansi_color'
require 'rubytools/numeric_ext'
using NumericExt
using DFExt

module Unicode
  # Chart characters
  BODY = "┃"
  BOTTOM = "╿"
  HALF_BODY_BOTTOM = "╻"
  HALF_BODY_TOP = "╹"
  FILL = "┃"
  TOP = "╽"
  VOID = " "
  WICK = "│"
  WICK_LOWER = "╵"
  WICK_UPPER = "╷"
  TEE_UP = "⊥"
  TEE_DOWN = "⊤"
  MIN_DIFF_THRESHOLD = 0.25
  MAX_DIFF_THRESHOLD = 0.75
  DENSITY_SIGNS = ['#', '░', '▒', '▓', '█'].freeze
  BOX_HORIZ = '─'.freeze
  BOX_HORIZ_VERT = '┼'
  BOX_VERT = WICK
end

module Plotter
  #
  # Unix-compatible Terminal OHLC data plotter
  # uses ANSI box drawing chars
  #

  module_function

  DENSITY_SIGNS = ['#', '░', '▒', '▓', '█'].freeze
  BOX_HORIZ = '─'.freeze
  # BOX_HORIZ = '-'
  # BOX_HORIZ_VERT = '┼'.freeze
  BOX_HORIZ_VERT = '┼'
  # BOX_VERT = '|'.freeze
  BOX_VERT = Unicode::WICK

  BAR_XLIMIT = 50
  @x_axis_limit = nil

  class << self
    attr_accessor :x_axis_limit
  end

  def initialize(**params)
    @x_axis_limit = params.fetch(:scale, 100/5)
    @label_width = params.fetch(:label_width, 1)
    @nocolor = params.fetch(:nocolor, false)
  end

  def xplot(data, **params, &block)
    bars = plot_map(data.deep_dup, &block)

    header = plot_horiz_labels(bars, data, **params)

    bars
    .tap{|br| br.prepend(header)}
    .map(&:reverse)
    .to_table(separator:'')
  end

  def plot_map(data, &block)
    #
    # block returns strategy
    # candlestick(*row, min, max)
    # openclose(*row, min, max)

    min, max = data.map { |r| r.values_at(1..-1) }.flatten.minmax
    data.map do |row|
      block.call(row, min, max)
    end
  end

  def label_format(label, label_width=6)
    nformat=->x{
      return x unless x.to_s.numeric?
      width = x < 1 ? label_width : 2
      x.to_f.to_human(width)
    }
    ->text{
        t=nformat[text]
        t.rjust(label_width)[0...label_width]
    }
    .call(label)
  end

  def plot_horiz_labels(bars, data, **params)
    min, max = data.dup.map(&:last).minmax
    label_width = params.fetch(:label_width, @label_width)
    Array
    .new(bars.transpose.size){'-'}
    .tap{|header|
      header[-1]=label_format(max, label_width)
      header[header.size/2]=label_format( (max+min)/2, label_width)
      header[0]=label_format(min, label_width)
    }
  end

end

class Candlestick
  #
  # Unix-compatible Terminal OHLC data plotter
  # uses ANSI box drawing chars
  #

  include Plotter

  def draw(_name, open, high, low, close, min = 0, max = 100, **params)
    #
    # plot an OHLC row as candlestick pattern
    # row format == [:row_1, o, h, l, c, min, max]
    #
    bar = [''] * @x_axis_limit

    up_down = (close <=> open)
    # normalize to zero x-axis
    open, low, high, close, min, max =
    [open, low, high, close, min, max]
    .map(&:to_f)
    .map{ |e| e - min.to_f }

    # normalize to percentage
    open, high, low, close =
    [open, high, low, close]
    .map { |e| (e / max) }
    .map{|e| e*@x_axis_limit }
    .map(&:to_i) # .map(&:floor)

    len = (high - low)
    bar.fill(low, (low + len), BOX_VERT)

    start, stop = [open, close].minmax
    len = (stop - start) # reuse len
    case len
    when 0
      start = [start - 1, 0].max
      bar[start] =
      case up_down
        when -1
          Unicode::TOP
        when 0
          Unicode::HALF_BODY_TOP
        when 1
          Unicode::BOTTOM
        else
          '#'
      end

    else
      start, stop = [open, close].minmax
      len = (stop - start).abs
      bar.fill(start, (start + len), Unicode::BODY)
    end

    return bar if @nocolor

    up_down.negative? ? bar.map(&:magenta) : bar.map(&:yellow)
  end

  def self.draw(open, high, low, close, min = 0, max = 100, **params)
    new(**params).draw('candle', open, high, low, close, min, max)
  end

  def plot(data, **params)
    xplot(data.deep_dup, **params){|row, min, max| draw(*row, min, max)}
  end


  def self.candle(open, high, low, close, min = 0, max = 100, **params)
    #
    # plot an OHLC row as candlestick pattern
    # row format == [:row_1, o, h, l, c, min, max]
    #
    bar_char=Unicode::DENSITY_SIGNS[-1]

    @x_axis_limit = params.fetch(:scale){ 20 }
    @color = params.fetch(:color){ true }

    bar = [' '] * @x_axis_limit

    up_down = (close <=> open)
    # normalize to zero x-axis
    open, high, low, close, min, max =
    [open, high, low, close, min, max]
    .map(&:to_f)
    .map{ |e| e - min.to_f }

    # normalize to percentage
    open, high, low, close =
    [open, high, low, close]
    .map{|e| e / max }
    .map{|e| e * @x_axis_limit }
    .map(&:to_i) # .map(&:floor)

    len = [(high - low).abs - 1, 0].max
    bar.fill(low, (low + len), Unicode::BOX_HORIZ)

    start, stop = [open, close].minmax
    len = (stop - start).abs # reuse len
    case len
    when 0
      start = [start - 1, 0].max # no negative numbers
      bar[start] = Unicode::BOX_HORIZ_VERT
    else
      bar.fill(start, (start + len), bar_char)
    end

    return bar unless @color

    up_down.negative? ? bar.map(&:light_magenta).join : bar.map(&:light_yellow).join
  end
end

class OpenClose
  include Plotter

  def draw(_name, open, close, min = 0, max = 100)
    #
    # plot an OC row as a directional bar pattern
    # row format == [:row_1, o, c, min, max]
    #
    bar = [''] * @x_axis_limit

    up_down = (close <=> open)
    # normalize to zero x-axis
    open, close, min, max = [open, close, min, max].map(&:to_f).map{ |e| e - min.to_f }
    # normalize to percentage
    open, close = [open, close].map { |e| (e / max) * @x_axis_limit }.map(&:to_i) # .map(&:floor)

    start, stop = [open, close].minmax
    len = (stop - start).abs
    case len
    when 0
      start = [start - 1, 0].max
      bar[start] = Unicode::HALF_BODY_TOP  # TODO: find center dot
    else
      start, stop = [open, close].minmax
      len = (stop - start).abs
      bar.fill(start, (start + len), Unicode::BODY)
    end

    return bar if @nocolor

    up_down.negative? ? bar.map(&:magenta) : bar.map(&:yellow)
  end

  def self.draw(open, high, low, close, min = 0, max = 100, **params)
    new.draw(nil, open, high, low, close, min, max, **params)
  end

  def plot(data)
    xplot(data.deep_dup){|row, min, max| draw(*row, min, max)}
  end
end


module ScalePlotter
  refine Numeric do
    def to_volume_bar(scale: 42, color: 'black', bg_color: 'light_black', quiet:false)
      vratio = self.clamp(0..100)
      ch=Unicode::HALF_BODY_BOTTOM
      tick=Unicode::TOP
      vbar_size = (vratio*(scale/100.0)).to_i
      trail_size = scale-vbar_size
      max_bar = ch * trail_size
      volume_bar = ch * vbar_size
      max_bar.chop! if vbar_size.zero?
      min_bar=[volume_bar.chop, ch.light_white].join
      [min_bar.send(color), max_bar.send(bg_color)].join
    end
    def puts_volume_bar(scale:42, color: 'black', bg_color: 'light_black', quiet:false)
      asciibar = to_volume_bar(scale:, color:, bg_color: , quiet:)
      puts asciibar
    end
  end
end

module DFPlotExt
  include NumericExt
  include DFExt
  include ScalePlotter

  refine Array do
    def init_plot
      each_cons(2).map.with_index{|e, i| [i, e].flatten }
    end

    def plot_candlestick(**params)
      # plot an OHLC dataframe
      plot_data = self #.map{|r| [r, r.min, r.max] }
      Candlestick.new(**params).plot(plot_data)
    end

    def plot_bars(**params)
      plot_data = self
      plot_data = init_plot unless first.is_a?(Array) && first.size==3
      OpenClose.new(**params).plot(plot_data)
    end

    def to_diff_bar(scale: 20, prev: :red, curr: :yellow)
      def diff_to_s(x, y, ch='#', scale:20)
        max=[x,y].map(&:abs).max.to_f
        nsize=(([x,y].to_diff.abs/max)*scale).clamp(1, scale-2)
        (ch*nsize)
      end

      prev, curr=Plotter::DENSITY_SIGNS.values_at(1, -1)
      [first, last].then{|a, b|
        c=a+b
        [diff_to_s(b, c, curr, scale:), diff_to_s(a, c, '#', scale:)].join.ljust(scale, '@')[0...scale-1]
      }
    end

  end
end
