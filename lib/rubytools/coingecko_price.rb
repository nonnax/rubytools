#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2021-09-10 11:50:27 +0800
module Coingecko
  module_function

  def get_olhc(symbol)
    open, low, high, close = IO.popen("price #{symbol}", &:read).split.values_at(1, 3, 2, 5)
    open, low, high, close = [open, low, high, close].map(&:to_f)
  end

  def get_ohlc(symbol)
    IO.popen("price #{symbol}", &:read).split.values_at(7, 2, 3, 1).map(&:to_f)
  end

  def ohlc(symbol, open = nil)
    close, h, l = IO.popen("price #{symbol}", &:read).split.values_at(1, 2, 3)
    open ||= close # open==close
    [open, h, l, close].map(&:to_f)
  end
end

def ask_time
  Time.now.to_s.scan(/\S+/).values_at(0, 1).join('T')
end

class Numeric
  def self.symbol_codes
    %i[
      bitcoin
      bitcoin-cash
      chainlink
      ethereum
      litecoin
      ripple
      uniswap
    ]
  end
  symbol_codes.each do |sym|
    define_method("#{sym}".gsub(/-/,'_')) do
      self * Coingecko.ohlc(sym)[0]
    end
    define_method("to_#{sym}".gsub(/-/,'_')) do
      self / Coingecko.ohlc(sym)[0]
    end

  end
end
