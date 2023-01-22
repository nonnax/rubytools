#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2021-10-02 23:55:26 +0800

require 'io/console'

class IO
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

  module Screen
    module_function

    def cursor_cmd
      {
        clear: "\033[2J",
        cursor_save:  "\033[s",
        cursor_restore: "\033[u",
        cursor_down: ->(n){ print "\033[#{n}A" },
        cursor_xy: ->(x,y){ print format("\033[%d;%dH", x, y) },
        cursor_hide: "\033[?25l",
        cursor_show: "\033[?25h"
      }
    end

    def printxy(x, y, text = '')
      cursor_save
      cursor_hide do
        print(format("\033[%d;%dH%s", x, y, text))
      end
      cursor_restore
    end
    alias gotoxy printxy

    def clear
      print cursor_cmd[__method__]
    end

    def cursor_save
      print cursor_cmd[__method__]
    end

    def cursor_restore
      print cursor_cmd[__method__]
    end

    def cursor_down(n)
      cursor_cmd[__method__][n]
    end

    def cursor_xy(x, y)
      cursor_cmd[__method__][x, y]
    end

    def cursor_hide(&block)
      print cursor_cmd[__method__]
      if block
        block.call
        cursor_show
      end
    end

    def cursor_show
      print cursor_cmd[__method__]
    end

    def quiet_draw
      # hides cursor while drawing on terminal
      cursor_hide
      yield
    ensure
      cursor_show
    end
    alias quiet quiet_draw

    def winsize
      # $stdout.winsize
      height = `tput lines`
      width = `tput cols`
      [height, width].map(&:to_i)
    end
  end
end

module Kernel
  include IO::Keyboard
  include IO::Screen
end
