#!/usr/bin/env ruby
# Id$ nonnax 2023-02-14 00:11:17

# CoArray, cooperative arrays. Initalized arrays are bounded, and iterate together.
#
# `map` schedules the iteration of instances
#
# `join` yields the mapped arrays and returns a new Array of mapped values
#
class CoArray < Array
  @fibers = {}
  
  def self.fibers
    @fibers
  end
  
  def initialize(n, &block)
    super(n)
    if block
      instance_eval(&block)
      return join()
    end
  end

  # `map` schedules the method to run
  #
  # the real iteration runs by a call to `join`
  alias _map map #no-doc
  private _map
  
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
     .then{|f| self.class.fibers[self.object_id]=f }
    self
  end
  
  # `join` iterates the instances alternately. 
  #
  # the method yields the mappings and returns an Array of maps
  # 
  def join(&block)
    vals=[]
    while self.class.fibers.values.any?(&:alive?)
      self.class.fibers.map do |obj_id, f|
        next unless f.alive?
        v = f.resume
        vals << v if Array===v
      end
    end
    vals.tap{|a| block&.call(a)}
  end 
end

# CoArrays
#
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
