#!/usr/bin/env ruby
require "json"
require "uri"
require "net/http"
require_relative "../lib/rubytools/cache"
require 'excon'

module Coingecko
  VERSION = "0.1.0"
  # not found
  extend self 
  def get
    coins=["bitcoin", 
    "ethereum", 
    "ripple", 
    "bitcoin-cash", 
    "litecoin", 
    # "the-graph",
    "aave",
    "uniswap",
    "chainlink" 
    # "enjincoin",
    # "compound-coin",
    # "basic-attention-token"
    ]
    list=[]

    url="https:/api.coingecko.com/api/v3/coins/markets?vs_currency=php&ids=#{coins.join(',')}&order=market_cap_desc&per_page=100&page=1&sparkline=false&price_change_percentage=24h,7d,14d,30d"
    res=Excon.get(url)
    data=JSON.parse(res.body, symbolize_names: true)
    keys=%i[id current_price high_24h low_24h price_change_percentage_24h price_change_percentage_30d]

    data.each do |coin|
      list<< coin.values_at(*keys).compact.join(",")
    end 
    list
  end
  
end

res=Cache.cached('coingecko', ttl: 30) do
  Coingecko.get
end

puts res
