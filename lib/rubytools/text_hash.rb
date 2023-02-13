#!/usr/bin/env ruby
# Id$ nonnax 2023-01-18 10:05:46
require 'file/filer'
require 'math/math_ext'
using MathExt
# transforms a two columned lines of 'key` `number' pairs into a hash
class TextHash
 def initialize(text)
   @text=text
 end
 def split_pairs(re=/\n+/)
   @text.split.flat_map(&:split).each_slice(2)
 end
 def to_h
  split_pairs
  .each_with_object({}){|pair, h|
    k, v = pair
    h[k]=v.to_number{v}
  }
 end
 def to_s
  JSON.pretty_generate(to_h)
 end
end
