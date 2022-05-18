#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2022-02-03 13:18:17 +0800
require 'nokogiri'
require 'httparty'

class NokoParty
  BROWSER = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_4) AppleWebKit/536.30.1 (KHTML, like Gecko) Version/6.0.5 Safari/536.30.1'
  def self.get(url)
    HTTParty
     .get(url, browser: BROWSER)
     .body
     .force_encoding('UTF-8')
     .then{ |html| Nokogiri::HTML(html) }
  end
end
