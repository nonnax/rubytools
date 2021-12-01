#!/usr/bin/env ruby
# Id$ nonnax 2021-12-01 16:43:18 +0800
module ArrayPaging
  def from(at)
    at=[0, at-1].max
    values_at(at..-1)
  end
  def window(at: 0, take: 5)
    at=[0, at-1].max
    (
      [min] + 
      from(at).take(take) +
      [max]
    ).uniq
  end
end

Array.include(ArrayPaging)
