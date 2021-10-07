#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2021-10-02 23:55:26 +0800

require 'io/console'

module Keyboard
  module_function

  def getchar
    # reads keyboard input without echo
    # special chars are prefixed with "[" i.e. "[A" (up-arrow)
    kbinput = []
    case ch = $stdin.getch
    when "\e"
      2.times { kbinput << $stdin.getch }
      # discard insert/delete/pgup/pgdn trailing char '~'
      $stdin.getch if %(2 3 5 6).include?(kbinput.last)
      kbinput
    else
      kbinput << ch
    end.join
  end
end

module ANSIScreen
  module_function

  def printxy(x, y, text = '')
    print(format("\033[%d;%dH%s", x, y, text))
  end
  alias gotoxy printxy

  def clear
    print "\033[2J"
  end

  def cursor_save
    print "\033[s"
  end

  def cursor_restore
    print "\033[u"
  end

  def cursor_down(n)
    print "\033[#{n}A"
  end

  def cursor_hide
    print "\033[?25l"
  end

  def cursor_show
    print "\033[?25h"
  end

  def draw
  	# controls cursor visibilty while putting output on terminal 
  	cursor_hide
  	yield
  ensure
  	cursor_show
  end	

  def winsize
    # $stdout.winsize
		height=`tput lines`
		width=`tput cols`
		[height, width].map(&:to_i)
  end
end

module Kernel
  include Keyboard
  include ANSIScreen
end
