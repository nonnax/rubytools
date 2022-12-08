#!/usr/bin/env ruby
# Id$ nonnax 2022-12-07 20:52:45
# simple blocking-fiber loop scheduler
#
# FiberTags.new do
#  # 1k times loop, default param (timeout: 0)
#  _1_000{
#   puts 'hi'
#  }
#  # execute loop every 5-sec
#  _every(timeout: 5){
#     puts 'ho'
#  }
#
# end
# hi
# ho
# hi
# ho
# ...
#
require 'time/time_expiry'

class FiberTags

  attr_accessor :fibers

  def initialize(&block)
    @fibers=[]
    instance_exec(self, &block)
    join
  end

  def _every(**params, &block)
    @fibers<<Fiber.new do
      expires=TimeExpiry.new params.fetch(:timeout, 0)
      loop do
        block.call if expires.expired?
        Fiber.yield
      end
    end
  end

  def _observable(*observers, **params, &block)
    @fibers<<Fiber.new do
      expires=TimeExpiry.new params.fetch(:timeout, 0)
      loop do
        observers.each(&block) if expires.expired?
        Fiber.yield
      end
    end
  end

  def join
    while @fibers.any?(&:alive?)
      @fibers.map do |f|
        next unless f.alive?

        f.resume
      end
    end
  end

  def method_missing(m, *a, **params, &block)
    @fibers<<Fiber.new do
      expires=TimeExpiry.new params.fetch(:timeout, 0)
      # loop m-times
      m.to_s.tr('_','').to_i.times do |i|
        block.call(i) if expires.expired?
        Fiber.yield
      end
    end if m.match?(/^_/)
  end

end
