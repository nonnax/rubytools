#!/usr/bin/env ruby
# Id$ nonnax 2021-09-10 11:50:27 +0800
module Coingecko
  extend self
  MOCK=false
  def get_olhc(symbol)
    if MOCK
      base_price=60
      open, high, low, close= [base_price+rand(20), base_price+rand(25)+10, base_price+rand(20)-10, base_price+rand(20)]
      low, high=[high, low, close].minmax
    else
      open, low, high, close=IO.popen("price #{symbol}", &:read).split.values_at(1, 3, 2, 5)
    end
    open, low, high, close = [open, low, high, close].map(&:to_f)
  end
  def get_ohlc(symbol)
    IO.popen("price #{symbol}", &:read).split.values_at(7, 2, 3, 1).map(&:to_f)
  end
  def ohlc(symbol, open=nil)
    close, h, l= IO.popen("price #{symbol}", &:read).split.values_at(1,2,3)
    open ||= close # open==close 
    [open, h, l, close].map(&:to_f)
  end  
end

def ask_time
  Time.now.to_s.scan(/\S+/).values_at(0,1).join('T')
end

class Numeric
	def self.symbol_codes
			%i[
				bitcoin
				bitcoin-cash
				chainlink
				ethereum
				ripple
				uniswap
			]
	end
	self.symbol_codes.each do |sym|
		define_method(sym){
			Coingecko.ohlc(sym)
		}
	end
end
