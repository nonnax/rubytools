#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2021-11-30 00:16:10 +0800
require 'ruby-xxhash'

module XXHSum
  module_function
  def xxhsum_io(text, bits: 64)
    IO.popen(['xxhsum', '-b', bits], 'w+') do |io|
      io.puts text
      io.close_write
      io.read
    end.split(/\s+/).first
  end

  def xxh32sum(text, seed:)
    xxhash(text, seed:)
  end

  def xxh64sum(text, seed:)
    xxhash(text, seed:, bit64: true)
  end

  def xxhash(text, seed: 0, bit64: false)
    # fast version
    message = bit64 ? :xxh64 : :xxh32
    XXhash.send(message, text, seed).to_s(36)
  end
  alias xxhsum xxhash
  
end

# String.include(XXHSum)
