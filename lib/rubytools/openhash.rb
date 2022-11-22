#!/usr/bin/env ruby
# Id$ nonnax 2022-11-21 19:42:44
class OpenHash #< BasicObject
  # lh=OpenHash.define{|h|
  # first_key :none     # local method call-style key assignment
  # h.id= 1             # openstruct-style
  # first_key= :invalid # just a local variable assignment. use the `h` to qualify as a key assignment. as above
  # blocky(%w[just ignore us]){[:me_only!]*5} # using an `alternative` block. the block supercedes params
  # }
  # add more keys
  # lh.define{
  #   boom= :panes # don't do this. this is just a local variable assignment
  # }
  # p lh.boing # nil
  # p lh.boing{[:boong]*5} # using an `alternative` block. returns the block if key not found/nil
  # p lh.to_h
 def initialize(h={}, &block)
  @h=h
  define(&block)
 end

 def self.define(**h, &block)
  new(**h, &block)
 end

 def define(&block)
  instance_exec(self, &block)
  self
 end

 def keys
  @h.keys
 end

 def [](k); @h[k] end
 def []=(k,v); @h[k]=v end
 def to_s
  [super, @h].join(" ")
 end
 def to_h; @h end
 alias :inspect :to_h

 def method_missing(m, *a, **opts, &block)
  unless a.empty?
    m = m.to_s.chomp('=').to_sym if m.match?(/=$/)
    @h[m] = block ?  block.call : a.first
  else
    @h[m] ? @h[m] : (block.call if block)
  end
 end
end


