#!/usr/bin/env ruby
# Id$ nonnax 2022-12-14 20:29:27

module EnumerableExt
 refine Enumerable do
  def each_step(step=1, &block)
    each_slice(step).map(&:first).map(&block)
  end

  def each_of(n)
   x=(size/n.to_f)
   each_slice(x.clamp(1..size))
  end

 end
end
