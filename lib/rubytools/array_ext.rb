#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2021-12-01 16:43:18 +0800
require 'rubytools/array_of_hashes'
require 'rubytools/array_grep'

module ArrayPaging
  def from(at)
    at = [0, at].max
    slice(at..-1)
  end

  def window(at: 0, take: 0)
    # return slice from at: to take:
    # has trailing left/head and right/tail
    take = (take / 2.0).floor
    left_at = [(at - take + 1), 0].max
    left = slice(left_at, take) || []
    right = slice(at, take) || []
    (
      [first] +
      left +
      right +
      [last]
    ).uniq
  end

  def pager(page: 1, take: 10)
    page = [page-1, 0].max*take
    self[page...(page+take)]
  end
end

module ArrayExt
 refine Array do
  # maps each  `step` interval  
  # optional: `at` selects which end of the slice to pick
  def each_step(step=1, at=:first, &block)
    each_slice(step)
    .map(&at)
    .map(&block)
    .to_a
  end

  # yields each n-divisions of array
  def each_of(n, &)
   x=(size/n.to_f)
   each_slice(x.clamp(1..size))
   .map(&)
   .to_a
  end

 end
end

module Enumerable

  # arr = (1..99).to_a
  # pager = arr.each_page(3) #returns an enumerator of n-sliced indexes
  #
  # arr.values_at(*pager.to_a[1]) # get page-1 values
  #
  # pages = pager.to_a
  # arr.values_at(*pages[0])
  #
  # num_pages = pager.size
  #
  # arr.values_at(*pager.next) #used as a generator
  def each_page(n=1, &)
    size.times.each_slice(n, &)
  end

  # def each_of(n)
   # x=(size/n.to_f)
   # each_slice(x.clamp(1..size))
  # end

end

Array.include(ArrayPaging)

