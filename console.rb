#!/usr/bin/env ruby
# Id$ nonnax 2021-10-02 23:55:26 +0800

require 'io/console'

module Keyboard
	extend self
	
	def getchar
	  # nonblocking read of a single keyboard input without echo 
	  # special chars prefixed are with "[" i.e. "[A" keyboard up arrow
	  kbinput=[]
	  case ch=STDIN.getch
	  when "\e"
	    2.times{kbinput<<STDIN.getch}
	    # discard insert/delete/pgup/pgdn trailing char '~'
	    STDIN.getch if %(2 3 5 6).include?(kbinput.last)
	    kbinput
	  else
	    kbinput<<ch
	  end.join
	end
end

module AnsiScreen
	extend self
	
	def printxy(x, y, text)
		print( "\033[%d;%dH%s" % [x, y, text])
	end
	def clear
		print "\033[2J"
	end
	def save
		print "\033[s"
	end
	def restore
		print "\033[u"
	end
	def down(n)
		print "\033[#{n}A"
	end
end

module Kernel
	include Keyboard
	include AnsiScreen
end
