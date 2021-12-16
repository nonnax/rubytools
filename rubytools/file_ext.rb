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

module NumberedFile
  def filename_succ
    basename = File.basename(self, '.*')
    ext = File.extname(self)
    out = nil
    bn=basename.dup
    loop do
      bn = bn.match(/\d+$/) ? bn.succ : "#{bn}_001"
      n=bn.match(/\d+$/).to_s.to_i.to_s
      bn.gsub!(/\d+$/, n.rjust(3, '0'))      
      out = "#{bn}#{ext}"
      break unless File.exist?(out)
    end
    out
  end
end

module SafeFileName
  def to_safename
    gsub(/[^\w\.]/, '_')
  end
end

String.include(SafeFileName)
String.include(SafeFileName)
String.include(NumberedFile)

