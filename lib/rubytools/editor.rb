#!/usr/bin/env ruby
# Id$ nonnax 2021-10-02 17:23:14 +0800
require 'tempfile'
class IO
  class << self
    def buffer(text, editor)    
      IO.popen(editor, 'w+') do |io|
        io.puts text
        io.close_write
        io.read
      end  
    end
    def tempfile(text, editor)
      Tempfile.create('internal') do |f|
        f.puts text
        f.rewind
        cmd=[editor, f.path].join(' ')
        IO.popen(cmd, &:read)
      end
    end
    def editor(text="", editor: ENV['EDITOR'], with: :buffer)
      send with, text, editor
    end
  end
end
