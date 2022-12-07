#!/usr/bin/env ruby
# Id$ nonnax 2022-11-25 19:07:39
require 'delegate'

module FiberTimesExt
 refine  Integer  do
   def fiber_times(&block)
     fi_block=proc{
       v=0
       self.times do |i|
        v, = block.call(i, v)
        Fiber.yield(i, v)
       end
     }
     Fiber.new(&fi_block)
   end
 end
end

class FiberJoinDeco<SimpleDelegator

  def self.define(&block)
    fibers=block.call([])
    FiberJoinDeco.new(fibers).join
  end

  def join
    while self.any?(&:alive?)
      self.each do |f|
        next unless f.alive?
        f.resume
      end
    end
  end
end
