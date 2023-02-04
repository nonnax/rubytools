#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2023-01-13 10:52:55
require 'rubytools/core_ext'
require 'coingecko/coin_gecko'
# require 'math/math_ext'
# require 'df/df_ext'
# using MathExt
# using DFExt
using CoingeckoExt

require 'df/df_plot_ext'

using DFPlotExt

module PlotTrio
 module_function
 def trio(*data, **opts)
  puts data.map{|e| e.round(15)}.prepend(0).plot_bars(**{label_width: 7, scale: 15}.merge(opts))
 end
end

module Scrapemathics
  include MathExt

  refine String do
    def scan_to_f(re = /[\d.,]+/)
      scan(re).map { |n| n.tr ',', '' }.map(&:to_f)
    end
    def desc
      scan_to_f.desc
    end
    def scan_plot(remove:'24h Low / 24h High', **opts, &block)
      s=tr(remove, '')
      s=block.call(s) if block
      PlotTrio.trio(*s.scan_to_f, **opts)
    end
    def coindesc
      CoinGecko.new(CoingeckoMarkets, self) do |coin|
        units = bank[:units].sum
        curr_amount = (coin.current_price*units).to_human_auto
        puts describe{|h|
          h.merge!(watch_price:, units: , bank_amount: bank[:amount].sum, curr_amount: , candle: price_candlestick)
          h.transform_values!{|v| v.to_s.numeric? ? v.to_human_auto : v }
        }.transpose.to_table
      end
    end
  end
  refine Hash do
   def display
    puts self.transpose.to_table
   end
  end
  refine Array do
    def desc
      %i[means sigma CV].zip([means, sigma.human(7), cv.human]).to_h.display
    end
    def pair_describe
      first_last.then do |pair|
        pair_delta = pair.then { |d| [[d, d.to_percent_change]].to_h }
        p pair_means = pair.means.map{|e| e.human.to_f}.uniq
        pair_mean_delta = pair.means.each_cons(2).map do |d|
          [[d.map do |e|
              e.human(9).to_f
            end, d.to_delta.to_percent.human.to_f]].to_h
        end
        pair_means_h = { mean: pair_means.mean.human.to_f }
        [pair_means_h, pair_delta, pair_mean_delta].flatten.inject(&:merge).transform_keys(&:inspect).reject{|k, v| v.zero?}

      end
    end
  end
end
