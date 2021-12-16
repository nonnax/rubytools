#!/usr/bin/env ruby
# frozen_string_literal: true
# Id$ nonnax 2021-09-10 11:50:27 +0800
# histoplot.rb
#   plots chronological data as vertical candlestick pattern ascii chart
# usage: histoplot.rb <csvfile> <colnum>
#
require 'csv'
require 'rubytools'
require 'ascii_plot'
require 'numeric_ext'
require 'fzf'

# f=Dir["*.*"].fzf.first
f, targetrow=ARGV

# fzf enabled
f=='fzf' && f=Dir['*.*'].fzf.first

# f, targetrow = ARGV
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
    .reject { |e| e.last<0 }

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
  # tmp
end

dataframe = data.build_df(target_row)

XLIMIT = 55
AsciiPlot.x_axis_limit = XLIMIT

if dataframe.size.positive?
   i=0
  df=[]
  dataframe.plot_df do |box, row|
    title = row[:title]
    min = row[:open]
    max = row[:close]
    rate = format('%.2f %%', (max / min - 1) * 100)
    suff=min<max ? ' ' : '-' 
    box=box.gsub(/\-/,'|')
	df<<title.to_s.rjust(15)[0..15]+box.uncolor	+ suff
  end
  puts df.last(150).to_hbars(delimeter: '  ')
end
