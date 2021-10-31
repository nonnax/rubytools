#!/usr/bin/env ruby
require "json"
require "uri"
require "net/http"
require "cache"

# TODO: Write documentation for `Coingecko`
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
    # "aave",
    "uniswap",
    "chainlink" 
    # "enjincoin",
    # "compound-coin",
    # "basic-attention-token"
    ]
    list=[]
    coins.each do |coin|
      # p coin
        url="https://api.coingecko.com/api/v3/coins/#{coin}?localization=false&tickers=false&market_data=true&community_data=false&developer_data=false&vs_currencies=php"
        uri = URI.parse(url)
        response = Net::HTTP.get_response(uri)
        next unless response.code == '200'
        data = JSON.parse(response.body)

        File.open("data.json", "a"){|f| f.puts data}

        r=[]
        market_data = data["market_data"]
        cprice=	market_data.dig("current_price", "php")
        price_change_percentage_24h= market_data.dig( "price_change_percentage_24h_in_currency", "php")
        price_change_percentage_7d=  market_data.dig( "price_change_percentage_7d_in_currency",  "php")
        price_change_percentage_14d= market_data.dig( "price_change_percentage_14d_in_currency", "php")
        price_change_percentage_30d= market_data.dig( "price_change_percentage_30d_in_currency", "php")
        price_change_percentage_60d= market_data.dig( "price_change_percentage_60d_in_currency", "php")
        price_change_percentage_200d= market_data.dig( "price_change_percentage_200d_in_currency", "php")

        lo, hi= market_data["low_24h"]["php"], market_data["high_24h"]["php"]

        r << coin[0..14].strip.ljust(15)
        r << ("%0.2f" % cprice.to_s.to_f)
        r << ("%0.2f" % hi.to_s.to_f.ceil)
        r << ("%0.2f" % lo.to_s.to_f.ceil)
        r << ("%0.2f" % price_change_percentage_24h.to_s.to_f)+"% 24h"
        r << ("%0.2f" % price_change_percentage_7d.to_s.to_f)+"% 7d"
        r << ("%0.2f" % price_change_percentage_14d.to_s.to_f)+"% 14d"
        r << ("%0.2f" % price_change_percentage_30d.to_s.to_f)+"% 30d"
        r << ("%0.2f" % price_change_percentage_60d.to_s.to_f)+"% 60d"
        r << ("%0.2f" % price_change_percentage_200d.to_s.to_f)+"% 200d"

        list << r.join(" ")
        sleep(0.5)
      rescue
        sleep(1)
        next

      end 

    # list.each do |e|
      # puts e
    # end
    list.join("\n")
  end
end

res=Cache.cached('coingecko', ttl: 120) do
  Coingecko.get
end

puts res
