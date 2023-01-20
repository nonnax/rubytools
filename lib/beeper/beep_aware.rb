#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2023-01-18 10:38:01
require 'beeper/beeper'

class BeepAware
  attr :range, :del, :len, :rep

  def initialize(del: 50, len: 60, rep: 2, &block)
    @range = {
      -100..-1 => 500,
      2..5 => 2000,
      6..100 => 4200
    }
    @del = del
    @len = len
    @rep = rep
    instance_exec(@range, &block) if block # allow custom key = [range, freq]
  end

  def between(range = (1..5), freq: 4000)
    @range[range] = freq
  end

  def when(n, &block)
    found = range.detect { |k, _v| n.between?(*k.minmax) }
    return unless found

    opts = { freq: found.last, del:, len:, rep: }
    Beeper.beep(**opts)
    block&.call(n, found.first)
  end
end
