#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2021-11-24 13:52:14 +0800
Thread.abort_on_exception = true
class Thread
  def self.array(&block)
    ts = []
    block.call(ts)
    ts.map(&:join)
  rescue StandardError
    ThreadError
  end
end
