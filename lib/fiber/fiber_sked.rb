#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2022-11-24 10:59:15
require_relative 'fiber_times'

class FiberSked
  attr :timer
  attr_accessor :fibers

  def self.define(timer = 0, &block)
    new(timer)
    .tap{|o| o.instance_exec(o.fibers, &block) }
    .join
  end

  def initialize(timer = 0, &block)
    @fibers = []
    @timer = timer
    tap{ instance_exec(@fibers, &block) }.join if block
  end

  def schedule(repeat = 1, v = nil, &block)
    body = proc do |_t|
      repeat.times do |i|
        v, = block.call(i, v)
        Fiber.yield(i, v)
        sleep @timer
      end
    end
    @fibers << Fiber.new(&body)
  end

  def join
    while @fibers.any?(&:alive?)
      @fibers.each do |f|
        next unless f.alive?

        f.resume
      end
    end
  end
end
