#!/usr/bin/env ruby
# Id$ nonnax 2022-08-24 15:19:03
class FileImporter
  # embed `afile` with @import '<afile>' directive
  RE_IMPORT = /
    @import\s*(\W)([\w.\/]+)\1
  /xm
  # any pair of non-word delimeters must match
  # @import 'file'
  # @import !file!
  # @import %file%
  def initialize(dir:'./')
    @dir=dir
  end
  # gsub_imports/puts is recursive.
  # if @import `afile` has another @import 'bfile' in it, it calls same method on itself
  def gsub_imports(_text)
    _text.gsub(RE_IMPORT){ File.read(File.join(@dir, Regexp.last_match[2])) }
         .then{|text| text.match?(RE_IMPORT) ? gsub_imports(text) : text }
  rescue=>e
    puts [e.to_s.split.last, "not found"].join(' ')
  end

  def self.parse(text, dir: './')
    new(dir: ).parse(text)
  end

  alias_method :puts, :gsub_imports
  alias_method :parse, :gsub_imports
end
