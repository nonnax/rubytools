#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2021-10-31 21:26:17 +0800
require 'ruby-filemagic'
require 'fileutils'
require 'pathname'

class String
  def is_text_file?
    # returns true/false

    fm = FileMagic.new(FileMagic::MAGIC_MIME)
    !fm.file(self).match(%r{^text/}).nil?
  ensure
    fm.close
  end
  alias text_file? is_text_file?

  def is_binary_file?
    !text?
  end
  alias binary_file? is_binary_file?
end


module SafeFileName
  def to_safename
    gsub(/[^\w.]+/, '_')
  end
end

module NumberedFile
  UNDERSCORE = '_'
  RE_END_DIGIT = /#{UNDERSCORE}\d+$/.freeze

  def get_next_name(bn, ext)
    out=nil
    loop do
      bn = bn.match(RE_END_DIGIT) ? bn.succ : "#{bn}_001"
      out = [bn, ext].join('.')
      break unless File.exist?(out)
    end
    out
  end

  def filename_succ(f)
    basename, _, ext = f.rpartition('.')
    out = nil
    bn=basename.empty? ? ext : basename # check dot-files
    get_next_name(bn, ext)
  end
  alias to_safe_filename filename_succ
end

# String.include(NumberedFile)
String.include(SafeFileName)


class File
  extend NumberedFile

  def self.File(file)
    file=file.to_path if file.respond_to?:to_path
    file=file.to_str
  end

  def self.splitname(f)
    [File.basename(f, '.*'), File.extname(f)]
  end

  def self.splitpath(f)
    f=f.to_path&.to_str if f.respond_to?:to_path
    f_basename = basename(f)
    [File.expand_path(f).gsub(f_basename, ''), f_basename]
  end

  def self.append(path, str)
    File.open(path, 'a+'){|f| f.puts str}
  end

  def self.age(f, attribute: :mtime) # :mtime, :atime, :ctime
    Time.now-File.send(attribute, f)
  end

  class << self
    alias safe_filename filename_succ
  end

  def self.backup(f)
    path, f_ = splitpath(f)
    FileUtils.cp(f, File.join(path, f_.filename_succ)) rescue nil
  end
end

module PathnameExt
  def backup
    path, f_ = split(f)
    FileUtils.cp(f, File.join(path, f_.filename_succ)) rescue nil
  end
  def filename_succ
    Pathname.new(File.filename_succ(self.basename))
  end
end
