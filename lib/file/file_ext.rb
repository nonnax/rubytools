#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2021-10-31 21:26:17 +0800
require 'ruby-filemagic'
require 'fileutils'
require 'pathname'
require 'file/file_importer'

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
  UNDERSCORE = '-'
  RE_END_DIGIT = /#{UNDERSCORE}\d+$/

  def get_next_name(bn, ext)
    out = nil
    loop do
      bn = bn.match?(RE_END_DIGIT) ? bn.succ : "#{bn}-001"
      out = [bn, ext].join('.')
      break unless File.exist?(out)
    end
    out
  end

  def filename_succ(f)
    basename, _, ext = f.rpartition('.')
    out = nil
    bn = basename.empty? ? ext : basename # check dot-files
    get_next_name(bn, ext)
  end
  alias to_safe_filename filename_succ

  def filename_next(f)
    fname = f.match?(RE_END_DIGIT) ? f : "#{f}-001"
    File.exist?(fname) ? filename_next(fname.succ) : fname
  end
end

# String.include(NumberedFile)
String.include(SafeFileName)

class File
  extend NumberedFile

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
    File.open(path, 'a+') { |f| f.puts str }
  end

  # :mtime, :atime, :ctime
  def self.age(f, attribute: :mtime)
    return 999_999_999 unless File.exist?(f)

    Time.now - File.send(attribute, f)
  end

  class << self
    alias safe_filename filename_succ
  end

  def self.backup(f)
    path, f_ = splitpath(f)
    begin
      FileUtils.cp(f, File.join(path, f_.filename_succ))
    rescue StandardError
      nil
    end
  end
  # open_lock(fname, mode = 'w', File::LOCK_EX | File::LOCK_NB) non-blocking lock
  def self.open_lock(fname, mode = 'r', lockmode = nil)
    lockmode ||= if %w[r rb].include?(mode)
                   File::LOCK_SH
                 else
                   # File::LOCK_EX
                   File::LOCK_EX | File::LOCK_NB
                 end
    value = nil
    open(fname, mode) do |f|
      flock(f, lockmode) do
        value = yield f
      ensure
        f.flock(File::LOCK_UN) # Comment this line out on Windows.
      end
      return value
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
