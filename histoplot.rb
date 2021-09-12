#!/usr/bin/env ruby
# frozen_string_literal: true
# Id$ nonnax 2021-09-10 11:50:27 +0800
# histoplot.rb
#   plots chronological data as vertical candlestick pattern ascii chart
# usage: histoplot.rb <csvfile> <colnum>
#
require 'asciiplot'
require 'numeric_ext'
require 'csv'

f, targetrow = ARGV
target_row = targetrow ? targetrow.to_i : 2

data = CSV.parse(File.read(f), converters: %i[numeric])

def data.build_df(target_row)
  # basic data cleanup
  tmp =
    map do |r|
      label, col = r.values_at(0, target_row)
      # to_f ensures zeros/headers are rejected
      [label, col.to_f]
    end
    .reject { |e| e.last.zero? }

  # init opening
  min, max = tmp.map(&:last).minmax
  open = tmp.shift.last

  tmp.each_with_object([]) do |r, acc|
    label, close = r
    # use tOHLC format:  ['title', o, h, l, c]
    acc << [
      label,
      open,
      max,
      min,
      close
    ]
    # update opening
    min, max = [open, close].minmax
    open = close
  end
end

dataframe = data.build_df(target_row)

XLIMIT = 52
AsciiPlot.x_axis_limit = XLIMIT

if dataframe.size.positive?
  dataframe.plot_df do |box, row|
    min = row[:open]
    max = row[:close]
    rate = format('%.2f %%', (max / min - 1) * 100)

    min, max = [min, max].map(&:to_f)
    puts [
      row[:title],
      min.commify.rjust(14),
      box,
      max.commify.rjust(14),
      rate.rjust(10)
    ].join(' ')
    puts
  end
end
