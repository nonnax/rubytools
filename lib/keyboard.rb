require 'io/console'

module Keyboard
  extend self
  def getchar
    # non-blocking read of a single keyboard input without echo 
    # special chars prefixed are with "[" i.e. "[A" keyboard up arrow
    kbinput=[]
    case ch=STDIN.getch
    when "\e"
      2.times{ kbinput<<STDIN.getchar }
      # discard insert/delete/pgup/pgdn trailing char '~'
      STDIN.getch if %(2 3 5 6).include?( kbinput.last )
      kbinput
    else
      kbinput<<ch
    end.join
  end
end
