#!/usr/bin/env ruby
# Id$ nonnax 2021-10-31 21:26:17 +0800
require 'ruby-filemagic'
require 'fileutils'

class String
  def is_text_file?
    # returns true/false
    begin
      fm = FileMagic.new(FileMagic::MAGIC_MIME)
      !(fm.file(self).match /^text\//).nil? 
    ensure
      fm.close
    end
  end
  alias text_file? is_text_file?

  def is_binary_file?
    !text?
  end
  alias binary_file? is_binary_file?
end

class File
  def self.splitname(f)
    [File.basename(f, '.*'), File.extname(f)]
  end
  def self.splitpath(f)
    f_basename = File.basename(f)
    [File.expand_path(f).gsub(f_basename, ''), f_basename]  
  end
  def self.filename_succ(f)
    f.filename_succ
  end
  def self.backup(f)
    f_=basename(f)
    FileUtils.cp(f_, f_.filename_succ)
  end
end

module SafeFileName
  def to_safename
    gsub(/[^\w\.]+/, '_')
  end
end

module NumberedFile
  UNDERSCORE='_'
  RE_END_DIGIT=/#{UNDERSCORE}\d+$/
  def filename_succ
    basename, ext = File.splitname(self)
    out = nil
    bn=basename.dup
    loop do
      bn = bn.match(RE_END_DIGIT) ? bn.succ : "#{bn}_001"
      out = "#{bn}#{ext}"
      break unless File.exist?(out)
    end
    out
  end
end

String.include(NumberedFile)
String.include(SafeFileName)
