#!/usr/bin/env ruby
# Id$ nonnax 2023-01-13 16:25:21
require 'file/filer'

def ARGV.captures(f=".#{File.basename($PROGRAM_NAME, '.*')}.log", &block)
   # load, or create cache and return or use default block val
   arg_to_i=->(f){f.scan(/\d+/).first.to_i}
   selected = self.uniq.sort{|a, b| arg_to_i[a]<=>arg_to_i[b] }

   filer, text = Filer.load(TextFile.new(f)){ selected.join("\n") }
   unless self.empty?
      args = text.split(/\n/).uniq
      combined_args = (args+selected).uniq
      filer.write combined_args.join("\n") unless (combined_args-args).empty?

      self
      .tap{|arr| arr.replace block.call if [block, arr.empty?].all? }
   else
     # return cache
     text.split(/\n/).uniq
   end
end
