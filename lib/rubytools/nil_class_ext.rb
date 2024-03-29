#!/usr/bin/env ruby
# Id$ nonnax 2022-11-19 14:11:22
module NilClassExt
 # sort-of a nil exception handler block for NilClass
 refine Object do
   # discard block if Object != NilClass
   def or(&block)
     self
   end
   def and(&block)
    block.call(self)
   end
 end

 refine NilClass do
   def or(&block)
    block.call
   end
   def and(&block)
     self
   end
 end
end
