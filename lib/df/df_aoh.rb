#!/usr/bin/env ruby
# Id$ nonnax 2023-02-21 14:00:24 +0800
require 'df/df_ext'
using DFExt

class AoH

  def initialize(data)
    @data=data
  end

  def each(&block)
    @data.each(&block)
  end

  def to_vectors
    @data.hashes_to_vectors
  end

  def join_h(other, on: nil, left:true)
    vectors=Hash.new{|h, k| h[k]=[] }
    p indexed = other.to_a.group_by { |r| r.values_at(*on) }
    indexed.default = []

    keys=(@data.map(&:keys) + other.map(&:keys)).flatten.uniq

    each do |r|
      matches = indexed[r.values_at(*on)]
      if matches.empty?
        if left
          keys.each do |k|
            vectors[k] << r[k]
          end
        end
      else
        matches.each do |r2|
          keys.each do |k|
            vectors[k] << (r2[k] || r[k])
          end
        end
      end
    end
    vectors
  end
end

a=[
{a: 1},
{a: 10},
{a: 5},
{a: 5},
{a: 20},
{a: 21, name: 'aha'},
]

# p a.hashes_to_vectors

other=[
{a: 1, name: 'a'},
{a: 10, name: 'b'},
{a: 10, name: 'b'},
{a: 15, name: 'z'},
{a: 15, name: 'aha'},
]

p AoH.new(a).join_h(other, on: :a)
p AoH.new(a).join_h(other, on: :a, left:false)
p AoH.new(a).to_vectors
p AoH.new(other).to_vectors
p AoH.new(other).join_h(a, on: :name)
# p other
