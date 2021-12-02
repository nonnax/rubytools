#!/usr/bin/env ruby
# Id$ nonnax 2021-12-01 16:43:18 +0800
module ArrayPaging
  def from(at)
    at=[0, at].max
    slice(at..-1)
  end
  def window(at: 0, take: 0)
    take=(take/2.0).floor
    left_at=[(at-take),0].max
    left=slice(left_at, take) || []
    right=slice(at, take) || []
    (
      [first] + 
      left + 
      right +
      [last]
    ).uniq
  end
end

Array.include(ArrayPaging)
