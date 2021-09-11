#!/usr/bin/env ruby
require 'forwardable'

class Coin
  extend Forwardable
  def_delegators :@ohlc_open, :empty?, :size, :map, :each, :[]
  attr_accessor :name, :open, :high, :low, :close, :ohlc_open
  
  def initialize(name, **params)
    @name = name
    @open = params[:open]
    @high = params[:high]
    @low = params[:low]
    @close = params[:close]
    @time = params[:time]
    @ohlc_open=[0,0,0,0]
  end
  def <<(data)
    @open, @high, @low, @close=data
    @time=ask_time
    ohlc
  end  
  def changed?
    # check and update if true
    res=(ohlc<=>@ohlc_open).zero?
    unless res
      update!
      yield self 
    end
    res
  end
  def update!
    @update=ohlc.dup
    # set open from previous close
    @update[0]=@ohlc_open.first unless @ohlc_open.first.zero?
    @ohlc_open=ohlc #reset
    @update
  end
  def ohlc
    [@open, @high, @low, @close]
  end
  def inspect
    t=[@time]
    t+@update
  end
  alias update inspect

  def ask_time
    Time.now.to_s.split[0..1].join('T')
  end

end


__END__
#---------------------
# test
require './lib/price_helper'

symbol=ARGV.first

ripple=Coin.new(symbol)

def ripple.price_update
    self<<Coingecko.ohlc(self.name)
end

loop do
  p ripple.price_update
  ripple.changed? do |r|
    p [:update, r.update]
  end
  sleep 15
end
