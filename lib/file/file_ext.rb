#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2021-10-31 21:26:17 +0800
require 'ruby-filemagic'
require 'fileutils'
require 'pathname'
require 'file/file_importer'
# require 'file/enable_cache'
require 'rubytools/editor'
require 'rubytools/cache'

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
  def to_pathname
    Pathname(self).expand_path
  end

  def to_safename
    gsub(/[^\w.]+/, '_')
  end
end

module NumberedFile
  UNDERSCORE = '-'
  RE_END_DIGIT = /#{UNDERSCORE}\d+$/

  def next_name(fname)
   File.basename(fname).partition('.') => [f, dot, ext]
   f = f[/\d{3}$/].nil? ? f+'-000' : f.succ
   fn = [f, dot, ext].join
   File.exist?(fn) ? next_name(fn) : fn
  end

  # backup!(`fname`) creates a new name if `fname` already exists
  def backup!(fname)
    dirname, f=File.splitpath(fname)
    File
    .join(dirname, next_name(f) )
    .tap{|valid_name|
      FileUtils.cp fname, valid_name
    }
  end

  alias to_safe_filename backup!
  alias filename_succ backup!

end

# String.include(NumberedFile)
String.include(SafeFileName)
File.extend NumberedFile

class File
  # extend NumberedFile

  def self.File(file)
    file = file.to_path if file.respond_to? :to_path
    file = file.to_str
  end

  def self.splitname(f)
    [File.basename(f, '.*'), File.extname(f)]
  end

  def self.splitpath(f)
    f = f.to_path&.to_str if f.respond_to? :to_path
    f_basename = basename(f)
    [File.expand_path(f).gsub(f_basename, ''), f_basename]
  end

  def self.append(path, str)
    File.write(path, str, mode: 'a+') # read-write append or create
  end

  # :mtime, :atime, :ctime
  def self.age(f, attribute: :mtime)
    return 999_999_999 unless File.exist?(f)

    Time.now - File.send(attribute, f)
  end

  class << self
    alias safe_filename filename_succ
  end

  def self.flock(f, mode)
    if f.flock(mode)
      begin
        yield f
      ensure
        f.flock(File::LOCK_UN)
      end
    end
  end

  # open_lock(fname, mode = 'w', File::LOCK_EX | File::LOCK_NB) non-blocking lock
  def self.open_lock(fname, mode = 'r', lockmode = File::LOCK_EX | File::LOCK_NB)
    lockmode = File::LOCK_SH if %w[r rb].include?(mode)
    open(fname, mode) do |f|
      flock(f, lockmode) do
        yield f
      end
    end
  end

  def self.locked?(f)
    f = File.open(f, File::CREAT)
    # returns false if already locked, 0 if not
    ret = f.flock(File::LOCK_EX | File::LOCK_NB)
    # unlocks if possible, for cleanup; this is a noop if lock not acquired
    f.flock(File::LOCK_UN)
    f.close
    !ret # ret == false means we *couldn't* get a lock, i.e. it was locked
  end
end

module PathnameExt
  def backup
    path, f_ = split(f)
    begin
      FileUtils.cp(f, File.join(path, f_.filename_succ))
    rescue StandardError
      nil
    end
  end

  def filename_succ
    Pathname.new(File.filename_succ(basename))
  end
end
