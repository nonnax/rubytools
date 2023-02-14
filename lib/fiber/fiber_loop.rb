#!/usr/bin/env ruby
# Id$ nonnax 2022-12-07 20:52:45
# simple blocking-fiber loop scheduler
#
# FiberLoop.new do
#  # 1k times loop, default param (timeout: 0)
#  _loop{
#   puts 'hi'
#  }
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

class FiberLoop

  attr_accessor :fibers

  def initialize(&block)
    @fibers=[]
    instance_exec(self, &block) if block
    at_exit { join }    
  end

  def every(timeout=0, **params, &block)
    Fiber
    .new(blocking: false) do
      expires=TimeExpiry.new params.fetch(:timeout, timeout)
      loop do
        block.call if expires.expired?
        Fiber.yield
      end
    end
    .tap do |fb|
      @fibers<<fb
    end
  end

  def each(enum, &block)
    Fiber
    .new(blocking: false) do
      enum.each do |e|
        block.call(e)
        Fiber.yield
      end
    end
    .tap do |fb|
      @fibers<<fb
    end
  end

  def loop(&block)
    Fiber
    .new(blocking: false) do
      Kernel.loop do |e|
        block.call(e)
        Fiber.yield
      end
    end
    .tap do |fb|
      @fibers<<fb
    end
  end

  def observable(timeout=0, *observers, **params, &block)
    Fiber
    .new(blocking: false) do
      expires=TimeExpiry.new params.fetch(:timeout, timeout)
      loop do
        expires.expired?{ observers.each(&block) }
        Fiber.yield
      end
    end
    .tap do |fb|
      @fibers<<fb
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

  # n-times loop
  # finite number of iterations 
  # use method format: `_int`.an (underscore) and an Integer. 
  #
  # _10 {|i| do_stuff(i) }
  #
  def method_missing(m, *a, **params, &block)
    return unless m.match?(/^_\d+/)
    
    @fibers<<Fiber
      .new do
        # loop m-times
        m.to_s.tr('_','').to_i.times do |i|
          block.call(i)
          Fiber.yield
        end
      end 
  end

end
