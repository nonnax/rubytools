#!/usr/bin/env ruby
# Id$ nonnax 2023-02-14 00:11:17

# CoArray
# Cooperative Arrays are bounded together internally
# when they alternately iterate with all other instances of CoArray(s)
#
class CoArray < Array
  @@fibers={}

  def initialize(n, &block)
    super(n)
    if block
      instance_eval(&block)
      join()
    end
  end

  # map only schedules the method
  # the actual iteration happens when `join` is called
  alias _map map
  def map(&block)
     maps=[]
     Fiber
     .new do
        _map do |e|
          v = block.call(e)
          maps << v
          Fiber.yield v
        end
      maps # last value returned to Fiber.resume
     end
     .then{|f| @@fibers[self.object_id]=f }
    self
  end
  
  # call join on any of the instance of CoArray objects runs `map` on all of them
  def join(&block)
    vals=[]
    while @@fibers.values.any?(&:alive?)
      @@fibers.map do |obj_id, f|
        next unless f.alive?
        v = f.resume
        vals << v if Array===v
      end
    end
    vals.tap{|a| block&.call(a)}
  end 
end

# CoArrays
# accepts regular arrays on initialization
# to act as cooperative CoArray(s)
class CoArrays

  attr :arrays

  def initialize(*arrays)
    @arrays=arrays
  end

  # map alternately maps the inialized arrays
  def map(&block)
    arrays
    .map{|a| CoArray.new(a) }
    .map{|ca| ca.tap{|c| c.map(&block) } } # CoArray.map
    .first
    .join
  end
end
