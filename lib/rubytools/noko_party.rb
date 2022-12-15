#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2022-02-03 13:18:17 +0800
require 'nokogiri'
require 'httparty'

class NokoParty
  BROWSER = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_4) AppleWebKit/536.30.1 (KHTML, like Gecko) Version/6.0.5 Safari/536.30.1'
  def self.default_handler(url)
    HTTParty
   .get(url, browser: BROWSER)
   .body
   .force_encoding('UTF-8')
  end
  def self.get(url, &block)
    http_handler = block&.call(url) || default_handler(url)
    http_handler
    .then{ |html| Nokogiri::HTML(html) }
  end
end
