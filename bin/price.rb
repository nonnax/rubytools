#!/usr/bin/env ruby
# frozen_string_literal: true

require 'excon'
require 'json'
require 'date'
require 'rubytools/cache'
require 'rubytools/hash_ext'
#
# url="https://api.coingecko.com/api/v3/coins/#{coin}?localization=false&tickers=false&market_data=true&community_data=false&developer_data=false&vs_currencies=php"

def help
  coins = %w[bitcoin
             ethereum
             ripple
             bitcoin-cash
             litecoin
             the-graph
             aave
             uniswap
             chainlink
             enjin-coin
             compound
             basic-attention-token]
  p coins.join(' ')
  puts ['USAGE:', __FILE__, coins.sample].join(' ')
end

def get_price_history(coin, date = '30-07-2021')
  url = "https://api.coingecko.com/api/v3/coins/#{coin}/history?date=#{date}"
  response = Excon.get(
    url
    #
    # headers: {
    # cache-control: 'max-age=30,public,must-revalidate,s-maxage=1800',
    # content-type: 'application/json; charset=utf-8'
    # }

  )
  data = JSON.parse(response.body)
  current_price = data.dig('market_data', 'current_price', 'php')
end

def get_price(*coins)
  coins.map do |coin|
    url = []

    url << "https://api.coingecko.com/api/v3/coins/#{coin}"

    url << {
      localization: false,
      tickers: false,
      market_data: true,
      community_data: false,
      developer_data: false,
      vs_currencies: :php
    }.to_query_string

    url = url.join('?')
    response = Excon.get(url)

    data = JSON.parse(response.body)
    current_price =
      data.dig('market_data',
               'current_price',
               'php')
    price_change_percentage_24h =
      data.dig('market_data',
               'price_change_percentage_24h_in_currency',
               'php')
    price_change_percentage_7d =
      data.dig('market_data',
               'price_change_percentage_7d_in_currency',
               'php')
    lo = data.dig('market_data',
                  'low_24h',
                  'php')
    hi = data.dig('market_data',
                  'high_24h',
                  'php')
    format('%s %.2f %.2f %.2f %%24h %.2f %%7d ',
           coin,
           current_price,
           hi,
           lo,
           price_change_percentage_24h,
           price_change_percentage_7d)
  end.join("\n")
end

if ARGV.empty?
  help
else
  stats = Cache.cached(ARGV.join, ttl: 15) do
    coins = *ARGV
    yesterday = (Date.today - 1).strftime('%d-%m-%Y')
    stats = get_price(*coins)
    sleep 1
    history = get_price_history(coins.first, yesterday)
    [*stats, history].join(' ')
  end
  puts stats
end
