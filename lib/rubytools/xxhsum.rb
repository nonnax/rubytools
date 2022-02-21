#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2021-11-30 00:16:10 +0800
require 'ruby-xxhash'

module XXHSum
  def xxhsum(h: 64)
    IO.popen('xxhsum', 'w+') do |io|
      io.puts self
      io.close_write
      io.read
    end.split(/\s+/).first
  end

  def xxh32sum(seed:)
    xxhash(seed:)
  end

  def xxh64sum(seed:)
    xxhash(seed:, bit64: true)
  end

  def xxhash(seed: 0, bit64: false)
    # fast version
    message = bit64 ? :xxh64 : :xxh32
    XXhash.send(message, self, seed).to_s(36)
  end
  
end

String.include(XXHSum)
