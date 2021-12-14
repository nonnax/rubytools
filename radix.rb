#!/usr/bin/env ruby
# Id$ nonnax 2021-12-07 19:43:05 +0800
def to_radix(int, radix)
  p [int, radix]
  int.zero? ? [] : (to_radix(int / radix, radix) + [int % radix])
end
