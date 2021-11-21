#!/usr/bin/env ruby
# Id$ nonnax 2021-10-31 21:26:17 +0800

class File
  def self.splitname(f)
    basename(f).split('.')
  end
end

module SafeFileName
  def to_safename
    gsub(/[^\w\.]/, '_')
  end
end

String.include(SafeFileName)

