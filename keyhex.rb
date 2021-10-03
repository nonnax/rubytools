#!/usr/bin/env ruby
# frozen_string_literal: true
require 'array_table'

def pairs
  l = ('a'..'z').to_a
  ',.!?'.chars.each{ |e| l.prepend(e) }
  x = 0
  until l.empty?
    x += 1
    group = [1,7,9].include?(x) ? 4 : 3
    g = l.slice!(0, group)
    idx=[x]*group
    g.zip(idx)
    yield g.zip(idx).to_h
  end
  n = (0..9).to_a
  yield n
  	.group_by(&:itself)
  	.to_h
  	.transform_values(&:first)
end

mapping = Hash.new
pairs {|h| mapping.merge!(h) }

puts mapping.map(&:join).each_slice(7).to_a.safe_transpose.to_table
# name = $stdin.read.downcase.chomp
name = ARGV.join
num_name = name.chars.map { |e|mapping[e] || 0 }
print num_name.join<< ' '
puts num_name.join.to_i.to_s(16)
