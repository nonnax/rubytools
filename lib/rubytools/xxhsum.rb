#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2021-11-30 00:16:10 +0800
require 'ruby-xxhash'

module XXHSum
  def xxhsum(h: 64)
    # IO.popen("xxhsum -H#{h}", "w+") do |io|
    IO.popen('xxhsum', 'w+') do |io|
      io.puts self
      io.close_write
      io.read
    end.split(/\s+/).first
  end

  def xxh32sum
    xxhsum(h: 32)
  end

  def xxhash(seed: 0, bit64: false)
    message = bit64 ? :xxh64 : :xxh32
    XXhash.send(message, self, seed)
  end
  
end

String.include(XXHSum)
