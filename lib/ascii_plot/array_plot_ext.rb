#!/usr/bin/env mruby
# frozen_string_literal: true

# Id$ nonnax 2021-08-22 20:38:32 +0800
# require 'rubytools/d_array_bars'
# $LOAD_PATH<<'./lib'
require 'df/df_ext'
require 'rubytools/ansi_color'
require 'ascii_plot/ascii_plot_ext'

using DFExt
using AsciiPlotExt

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
end

module Plotter
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


  def plot_horiz_labels(bars, data, **params)
    min, max = data.dup.map(&:last).minmax
    label_width = params.fetch(:label_width, @label_width)
    label_format=->text{ text.to_s.rjust(label_width) }
    Array
    .new(bars.transpose.size){'-'}
    .tap{|header|
      header[-1]=label_format[max]
      header[header.size/2]=label_format[(max+min)/2]
      header[0]=label_format[min]
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
    open, low, high, close, min, max = [open, low, high, close, min, max].map(&:to_f).map{ |e| e - min.to_f }

    # normalize to percentage
    open, high, low, close = [open, high, low, close].map { |e| (e / max) * @x_axis_limit }.map(&:to_i) # .map(&:floor)

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
          BOX_HORIZ_VERT
        when 1
          Unicode::BOTTOM
        else
          0
      end

    else
      start, stop = [open, close].minmax
      len = (stop - start).abs
      bar.fill(start, (start + len), Unicode::BODY)
    end
    up_down.negative? ? bar.map(&:magenta) : bar.map(&:cyan)
  end

  def plot(data, **params)
    xplot(data.deep_dup, **params){|row, min, max| draw(*row, min, max)}
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
      bar[start] = BOX_HORIZ_VERT
    else
      start, stop = [open, close].minmax
      len = (stop - start).abs
      bar.fill(start, (start + len), Unicode::BODY)
    end

    up_down.negative? ? bar.map(&:magenta) : bar.map(&:cyan)
  end

  def plot(data)
    xplot(data.deep_dup){|row, min, max| draw(*row, min, max)}
  end
end

module ArrayPlotExt
  refine Array do
    def plot_candlestick(**params)
      # plot an OHLC dataframe
      Candlestick.new(**params).plot(self)
    end
    def plot_bars(**params)
      OpenClose.new(**params).plot(self)
    end
  end
end

