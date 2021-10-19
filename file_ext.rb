#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2021-10-18 14:11:41 +0800
require 'fileutils'

module FileBackup
  def prefix(f)
    # generete date computed file name 
    fn=File.basename(f)
    t = Time.now
    "#{[t.yday, t.hour, t.min, t.sec].sum}_#{fn}"
  end
  def suffix(f)
    # generete date computed file name 
    fn, ext = File.basename(f).split('.')
    t = Time.now
    "#{fn}_#{[t.yday, t.hour, t.min, t.sec].sum}.#{ext}"
  end
  def mkbak(f, apply: :prefix)
    # make backup
    FileUtils.cp(f, "_#{send(apply, f)}")
  end
end

Kernel.include(FileBackup)
