#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2022-12-08 15:38:42
class TimeExpiry
  attr :timeout

  def initialize(timeout = 0)
    @timeout = timeout
    @expiry = Time.now + timeout
  end

  def expired?(reset: true, &block)
    t = Time.now
    if t > @expiry
      reset(t) if reset
      block&.call(t)
      true
    end
  end

  def reset(t)
    @expiry = t + timeout
  end
end
