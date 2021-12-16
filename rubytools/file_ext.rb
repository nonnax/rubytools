#!/usr/bin/env ruby
# Id$ nonnax 2021-10-31 21:26:17 +0800

class File
  def self.splitname(f)
    [File.basename(f, '.*'), File.extname(f)]
  end
  def self.filename_succ(f)
    f.filename_succ
  end
end

module SafeFileName
  def to_safename
    gsub(/[^\w\.]/, '_')
  end
end

module NumberedFile
  RE_END_DIGIT=/\d+$/
  UNDERSCORE='_'
  def filename_succ
    basename, ext = File.splitname(self)
    out = nil
    bn=basename.dup
    loop do
      bn = bn.match(RE_END_DIGIT) ? bn.succ : "#{bn}_001"
      n=bn.match(RE_END_DIGIT).to_s.to_i.to_s
      bn.gsub!(/#{UNDERSCORE}?#{RE_END_DIGIT}/, "#{UNDERSCORE}#{n.rjust(3, '0')}")      
      out = "#{bn}#{ext}"
      break unless File.exist?(out)
    end
    out
  end
end

String.include(SafeFileName)
String.include(NumberedFile)

