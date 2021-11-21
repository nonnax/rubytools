#!/usr/bin/env ruby
# Id$ nonnax 2021-11-08 12:50:01 +0800
require 'coingecko_price_ext'

text=gets
print text+"\t"

res=begin
  eval(text)
rescue
  eval( text.gsub(%r{[^\d.+-/*()\[\]]|\,},''))
end

print res
