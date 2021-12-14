#!/usr/bin/env ruby
# Id$ nonnax 2021-11-22 11:03:24 +0800
p str =<<~DOC 
      Having used Kaspersky Antivirus in the past, and been highly impressed,
      I found myself looking for a new antivirus for a freshly built PC!!!
      This is a sentence that should not match&hellip;
      I\\'d been using AVG 7.5 for the last year, and after becoming fed up of
      being nagged to use the paid version of AVG8 I decided to try the latest
      offering from Kaspersky Labs, in the form of the 2009 version of their anti-virus software.
DOC

# 
# 
bound = '(?:[!?.;]+|&hellip;)'
filler = '(?:[^!?.;\\d]|\\d*\\.?\\d+)*'
keyword = 'virus'
str.match(/#{bound}(#{filler}#{keyword}#{filler})(?=#{bound})/i) do |m|
  p m
end
# echo $str, '<hr/><pre>', print_r($matches, true), '</pre>';
