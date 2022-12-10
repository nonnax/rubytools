#!/usr/bin/env ruby
# Id$ nonnax 2022-12-09 10:58:57
require 'rubytools/numeric_ext'

module MathExt
 include NumericExt
 refine Numeric do
  def delta_change(to)
   Float(to)/self-1
  end
  alias delta delta_change
 end
end
