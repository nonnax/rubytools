# frozen_string_literal: true
# Markamini-inspired markup-builder
require 'rubytools/thread_ext'

class Scooby < BasicObject
  def initialize
    @node = nil
  end

  def self.dooby(&block)
     new.instance_eval(&block).to_s     # toplevel @node.to_s
  end

  def method_missing(tag, opts = {}, &block)
    @node = ::Node.new(@node, tag, opts)
    if block
      res = block.call
      @node.children << res if res.is_a?(::String)
    end
    # toplevel parent @node returned at tail of recursion
    @node = @node.parent || @node
  end
end

class Node
  attr_reader :tag, :parent
  attr_accessor :children

  def initialize(parent, tag, opts = {})
    @parent = parent
    @tag = tag
    @options = opts
    @children = []
    @parent.children << self if @parent
    if opts.is_a?(String)
      @options = {}
      @children = [opts]
    end
  end

  def to_s
    if children.size.positive?
      "<#{tag}#{options}>#{children.join(' ')}</#{tag}>\n"
    else
      "<#{tag}#{options}/>\n"
    end
  end

  def options
    @options.map { |k, v| " #{k}=#{v.inspect}" }.join
  end
end


# require 'cache'

module Kernel
	def render(**h, &block)
		if f=h[:cache]
			ttl=(h[:ttl] ||= 300)
			p "fetching cache...#{ttl}"
			Cache.cached(f, ttl: ttl) do
				Scooby.dooby(&block)
			end
		else
			Scooby.dooby(&block)
		end
	end
end

__END__
if $PROGRAM_NAME==$0 then

  html = Scooby.dooby do
    @arr = (21..23).to_a

    html do
      head do
        meta tag: 'charset', content: 'utf-8'
        title 'hi'
      end
      body do
        ul(id: 'foo') do
          li 'A div block'
          2.times { |x| li { "#{x}\n" } }
          @arr.each { |x| div(class: 'greet') { "hello#{x}\n" } }
        end
      end
    end
  end
end
puts html

__END__
Scooby.new.instance_eval
----+
		|
		+ method_missing
			|
			+ tag, opts = {}, &block # <initial>
			|
    	+	@node = Node.new(@node, tag, opts)
    	+	# @node = Node.new(nil, tag, opts) #parent intially nil
    			+
    			|
    	 		+	{node instance} if opts.is_a?(String)
				    									@children = [opts] # String is foreign node child. Node.to_s will be ignored
				    									@options = {}  
				    								else
				    									@options = opts	#options hash 
				    								end
											    	|
											    	+ @parent.children << self if @parent
    	|
    	+	if block
      |
      +		ret = block.call 
      |
      +		@node.children << ret if ret.is_a?(String)
      +		# else return from recursion @node.parent as current @node 
    	|
    	+	end
    	|
    	+	if @node.parent 
    	|		@node = @node.parent # return node parent 
    	+ else # @node.parent == nil
    	|		@node # node is toplevel parent
    	+	end

