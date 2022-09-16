#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2021-10-02 17:23:14 +0800
require 'tempfile'
class IO
  class << self
    def editor(text = '', editor: 'micro', tempfile: false)
      use = tempfile ? :_tempfile : :_buffer
      send use, text, editor
    end
    private

    def _buffer(text, editor)
      IO.popen(editor, 'w+') do |io|
        io.puts text
        io.close_write
        io.read
      end
    end

    def _tempfile(text, editor)
      Tempfile.create('internal') do |f|
        f.puts text
        f.rewind
        cmd = [editor, f.path].join(' ')
        IO.popen(cmd, &:read)
      end
    end
  end
end

module FileEditor
    def edit(filepath, editor: ENV['EDITOR'])
       File.write filepath, '' unless File.exist?(filepath)
       system(editor, filepath)
       File.read filepath
    end
end

File.extend(FileEditor)
