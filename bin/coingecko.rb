#!/usr/bin/env ruby
require "json"
require "uri"
require "net/http"
require "rubytools/cache"
require "rubytools/hash_ext"
require 'excon'


module Coingecko
  # url = "https://api.coingecko.com/api/v3/coins/markets?vs_currency=php&ids=#{coins.join(',')}
  # &order=market_cap_desc&per_page=100
  # &page=1&sparkline=false&price_change_percentage=24h,7d,14d,30d,90d"
  VERSION = "0.1.0"
  # not found
  extend self 
  def get
    coins=["bitcoin", 
    "ethereum",
    "ripple",
    "bitcoin-cash",
    "litecoin",
    "the-graph",
    "aave",
    "uniswap",
    "chainlink",
    "enjincoin",
    "compound-coin",
    "basic-attention-token"]
    list=[]
    
    qstr={
      vs_currency:'php',
      ids: coins.join(','),
      order: 'market_cap_desc',
      per_page: 100,
      page:1,
      sparkline: false,
      price_change_percentage: %w[24h 7d 14d 30d 90d]
    }
    
    url = ["https://api.coingecko.com/api/v3/coins/markets", qstr.to_query_string].join('?')
    
    res=Excon.get(url)
    data=JSON.parse(res.body, symbolize_names: true)
    keys=%i[id current_price high_24h low_24h price_change_percentage_24h price_change_percentage_30d_in_currency]

    data.each do |coin|
      list<< coin.values_at(*keys).join(',')
    end 
    list.prepend(keys.map(&:to_s).map{|e| e.gsub(/change_percentage/, 'delta').gsub(/in_currency/,'php')}.join(','))
    list
  end
  
end

res=Cache.cached('coingecko', ttl: 30) do
  Coingecko.get
end

puts res
