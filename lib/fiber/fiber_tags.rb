#!/usr/bin/env ruby
# Id$ nonnax 2022-12-07 20:52:45
# simple blocking-fiber loop scheduler
#
# FiberTags.new do
#
#  _1_000{
#   puts 'hi'
#  }
#  _10{
#   puts 'ho'
#  }
#
# end
# hi
# ho
# hi
# ho
# ...

class FiberTags

  attr_accessor :fibers

  def initialize(&block)
    @fibers=[]
    instance_exec(self, &block)
    join
  end

  def join
    while @fibers.any?(&:alive?)
      @fibers.each do |f|
        next unless f.alive?

        f.resume
      end
    end
  end

  def method_missing(m, *a, **params, &block)
    @fibers<<Fiber.new do
      timeout=Time.now + params.fetch(:timeout, 0)
      m.to_s.tr('_','').to_i.times do |i|
        block.call(i) if Time.now > timeout
        Fiber.yield
      end
    end if m.match?(/^_/)
  end

end
