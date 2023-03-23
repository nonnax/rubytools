#!/usr/bin/env mruby
# frozen_string_literal: true

# Id$ nonnax 2021-08-22 20:38:32 +0800
# require 'rubytools/d_array_bars'
# $LOAD_PATH<<'./lib'
require 'df/df_ext'
require 'rubytools/ansi_color'
require 'rubytools/numeric_ext'
require 'ascii_plot/ascii_plot'
require 'df/d_dfplot'
require 'ascii_plot/gnuplot'
require 'df/mod_unicode'
require 'sparkr'
require 'rbcat'

using NumericExt
using DFExt


#
# Unix-compatible Terminal OHLC data plotter
# uses Unicode/ANSI box drawing chars
#
module Plotter

  module_function

  @x_axis_limit = nil

  class << self
    attr_accessor :x_axis_limit
  end

  def initialize(**params)
    @params = params
    @x_axis_limit = params.fetch(:scale, 100/5)
    @label_width = params.fetch(:label_width, 1)
    @nocolor = params.fetch(:nocolor, false)
  end

  def xplot(data, **params, &block)
    bars = data_remap(data.deep_dup, &block)

    header = plot_horiz_labels(bars, data, **params)

    bars
    .prepend(header)
    .map(&:reverse)
    .to_table(separator:'')

  end

  # data_remap
  # block yields to a `strategy`:
  # candlestick(*row, min, max)
  # openclose(*row, min, max)
  def data_remap(data, &block)
    min, max = data.map { |r| r.values_at(1..-1) }.flatten.minmax

    data.map do |row|
      block.call(row, min, max)
    end
  end

  # label_format
  # auto-justifies y-label widths
  #
  def label_format(label, label_width=6)
    nformat=->x{
      return x unless x.to_s.numeric?
      width = x < 1 ? label_width : 2
      x.to_f.to_human(width)
    }
    ->text{
        t=nformat[text]
    }
    .call(label)
  end

  def plot_horiz_labels(bars, data, **params)
    min, max = data.dup.map(&:last).minmax # closing values only
    label_width = params.fetch(:label_width, @label_width)
    ylabel=
    Array
    .new(@x_axis_limit){'-'}

    ylabel.map.with_index{|_, y|
      ylabel[y] = label_format(min+(y*(max-min)/@x_axis_limit), label_width) if (y%4).zero?
    }
    ylabel[-1] = label_format(max, label_width)
    ylabel.map(&:to_s).map{|e| e.rjust(label_width)+' '}
  end

end

class Candlestick
  #
  # Unix-compatible Terminal OHLC data plotter
  # uses ANSI box drawing chars
  #

  include Plotter

  # draw
  # draw an OHLC row as a candlestick
  # row format == [:row_1, o, h, l, c, min, max]
  #
  def draw(_name, open, high, low, close, min = 0, max = 100, **params)
    bar = Array.new(@x_axis_limit){''} #[''] * @x_axis_limit

    up_down = (close <=> open)
    # normalize to zero x-axis
    open, low, high, close =
    [open, low, high, close]
    .map(&:to_f)
    .map{|e| (e-min)/(max-min)*@x_axis_limit}
    .map{|x| x.clamp(0..@x_axis_limit)}

    # draw wicks
    len = (high - low).abs.round
    bar.fill!(low.round, (low.round + len), Unicode::BOX_VERT)

    # draw body
    start, stop = [open, close].minmax
    len = (stop - start).abs.round # reuse len
    case len
    when 0
      bar[start.round] =
      case up_down
        when -1
          Unicode::TOP
        when 0
          Unicode::WICK
        when 1
          Unicode::BOTTOM
        else
          '#'
      end
    else
      bar.fill!(start.round, (start.round + len), Unicode::BODY)
      if (stop-high).abs.between?(0, 0.25)
        bar[start.round + len]=Unicode::HALF_BODY_BOTTOM
      elsif (stop.to_f-high.to_f).abs.between?(0.26, 0.5)
        bar[start.round + len]=Unicode::TOP
      end
      bar
    end

    return bar if @nocolor

    up_down.negative? ? bar.map(&:magenta) : bar.map(&:yellow)
  end

  def self.draw(open, high, low, close, min = 0, max = 100, **params)
    new(**params).draw('candle', open, high, low, close, min, max)
  end

  def plot(data)
    params = @params
    label_width = params.fetch(:label_width){data.map{|h| h.values_at(1..-1).flatten}.flatten.map(&:to_s).map(&:size).max+1}
    params[:label_width]=label_width

    xplot(data.deep_dup, **params){|row, min, max| draw(*row, min, max)}
  end

end



class Candlestick
  BOX_HORIZ = '-'
  BOX_HORIZ_VERT = '+'
  BOX_HORIZ_DOGI = '|'
  def self.candle(open, high, low, close, min = 0, max = 100, **params)
    #
    # plot an OHLC row as candlestick pattern
    # row format == [:row_1, o, h, l, c, min, max]
    #
    # bar_char=Unicode::DENSITY_SIGNS[-1]

    bar_char_table=[1, -1].zip(Unicode::VERTICAL_RECTANGLES).to_h

    # bar_char_table[1] = Unicode::DENSITY_SIGNS[-1]
    # bar_char_table[-1] = Unicode::DENSITY_SIGNS[1]
    # bar_char_table[1] = Unicode::SQUARE_BLACK
    # bar_char_table[-1] = Unicode::SQUARE_WHITE
    # bar_char_table[1] = Unicode::SQUARE_BLACK
    # bar_char_table[-1] = Unicode::SQUARE_WHITE

    @x_axis_limit = params.fetch(:scale){ 20 }
    @color = params.fetch(:color){ false }

    plot_bar = Array.new(@x_axis_limit){''}

    plot_bar.tap do |bar|
      up_down = (close <=> open)

      bar_char =
      bar_char_table
      .fetch(up_down){ bar_char_table[1] }

      # normalize to zero x-axis
      open, high, low, close, min, max =
      [open, high, low, close, min, max]
      .map(&:to_f)
      .normalize_axis(min)

      # normalize to percentage
      open, high, low, close =
      [open, high, low, close]
      .map{|e| e / max }
      .map{|e| e * @x_axis_limit }
      .map(&:to_i) # .map(&:floor)

      len = (high - low)
      bar.fill!(low, (low + len), BOX_HORIZ)

      start, stop = [open, close].minmax
      len = (stop - start).abs  # reuse len
      case len
      when 0
        # start = [start - 1, 0].max # no negative numbers
        if [close, open, high].uniq.uniq!
          bar[start] = BOX_HORIZ_DOGI
        else
          bar[start] = BOX_HORIZ_VERT
        end
      else
        # start, stop = [open, close].minmax
        # len = (stop - start).abs
        # up_or_down = ->(a, b){ up_down.negative? ? a : b }
        # bar_up_or_down = ->(){ up_down.negative? ? Unicode::SQUARE_WHITE : Unicode::SQUARE_BLACK }

        bar.fill!(start, (start + len + 1), bar_char)

        # x=up_or_down[start, (start + len)]
        # bar[x] = bar_up_or_down[]
      end
      # return bar.join unless @color
    end
    # up_down.negative? ? bar.join.light_magenta : bar.join.light_yellow
  end
end

class OpenClose
  include Plotter

  def draw(_name, open, close, min = 0, max = 100)
    #
    # plot an OC row as a directional bar pattern
    # row format == [:row_1, o, c, min, max]
    #
    bar = Array.new(@x_axis_limit){''}

    up_down = (close <=> open)

    # normalize to zero x-axis
    # normalize to percentage
    open, close =
    [open, close]
    .map { |e| (e-min)/(max.to_f-min) * @x_axis_limit }
    .map(&:round) # .map(&:floor)

    start, stop = [open, close].minmax.map{|e| e.clamp(0, @x_axis_limit)}

    len = (stop - start).abs

    case len
    when 0
      # start = [start - 1, 0].max
      bar[start] = Unicode::WICK  # TODO: find center dot
    else
      bar.fill!(start, (start + len), Unicode::BODY)
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
      ch = Unicode::HALF_BODY_BOTTOM
      tick = Unicode::TOP
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

# Barchart `data` is an array of hashes, row format: {k => v}
class BarChart
  attr :scale, :percent_bars, :max
  def initialize data=[], scale: 20
    @data = data
    @percent_bars=[]
    @scale = scale
    @max=data.map(&:values).flatten.max
    @keywidth=data.map(&:keys).flatten.map{|k| k.to_s.split(//).size}.max
  end

  def build
    @data.each do |h|
      k, v = h.to_a.flatten
      percent_bar(k, v)
    end
  end

  def percent_bar(k, v)
    # @percent_bars<<format("%s %02d %03d ", (Unicode::BODY*((v/max.to_f)*scale)).rjust(@scale), k, (v/max.to_f)*100 )
    val = (v/max.to_f)*scale
    body = val.to_i.zero? ?  Unicode::HALF_BODY_BOTTOM : Unicode::BODY * val
    @percent_bars<< [body.rjust(@scale+1), k.to_s.ljust(@keywidth+1)].join(' ')
  end

  def display
    build
    chart = AsciiPlot.new(percent_bars).rotate_strings(separator: '')
    chart
    .split("\n")
    .map
    .with_index{|r, i|
      percent = (((scale-i)/scale.to_f)*100).to_i
      i < scale ? r.prepend(percent.to_s.rjust(3)+' - ') : r.prepend((' '*3)+' . ')
    }
    .then(&method(:puts))
  end
  alias render display
end

module DFPlotExt
  include NumericExt
  include DFExt
  include ScalePlotter
  # include ArrayBarsExt

  refine Array do
    def init_plot
      each_cons(2).map.with_index{|e, i| [i, e].flatten }
    end

    # plot an OHLC dataframe as candlesticks
    def plot_candlestick(**params)
      raise 'invalid ohlc data' unless first.is_a?(Array) && first.size >= 5
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

      prev, curr = Unicode::DENSITY_SIGNS.values_at(1, -1)
      [first, last].then{|a, b|
        c=a+b
        [diff_to_s(b, c, curr, scale:), diff_to_s(a, c, '#', scale:)].join.ljust(scale, '@')[0...scale-1]
      }
    end

   using MathExt
   def to_sparkline
     # increase magnitude to handle numbers below 1
     sample=
     if self.mean<1
       self.map{|x| x*(10**max.decimal_places)}
     else
       self
     end
     Sparkr.sparkline(sample)
   end

   def to_sparkline_pairs
     self.zip(self.to_sparkline.split(//))
   end

   def to_sparkline_colors(join:"", &block)
      self.to_sparkline_pairs.map{|val, spark |
        color = val.negative? ? 'red' : 'yellow'
        spark.send(color).tap{|sp|
          block&.call(sp, val)
        }
      }.join(join)
   end

   def to_sparkline_chart
      chart=[]
      self.to_sparkline_colors{|spark, val|
        chart<<[spark, val.to_s.split(//).map(&:white)].flatten
      }
      chart.to_table
   end
  end
end
