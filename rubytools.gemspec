#!/usr/bin/env ruby
# Id$ nonnax 2021-12-16 14:28:13 +0800
files=%w[rubytools.rb
rubytools/ansi_color.rb
rubytools/array_ext.rb
rubytools/array_table.rb
rubytools/arraycsv.rb
rubytools/asciiplot.rb
rubytools/cache.rb
rubytools/coingecko_price.rb
rubytools/console_ext.rb
rubytools/core_ext.rb
rubytools/cubadoo.rb
rubytools/editor.rb
rubytools/file_ext.rb
rubytools/fzf.rb
rubytools/hash_ext.rb
rubytools/keyboard.rb
rubytools/methods_view.rb
rubytools/numeric_ext.rb
rubytools/pipe_argv.rb
rubytools/scooby.rb
rubytools/string_bars.rb
rubytools/string_ext.rb
rubytools/thread_ext.rb
rubytools/time_and_date_ext.rb
rubytools/xxhsum.rb]

bins=%w[catcsv.rb
coingecko.rb
console.rb
csvedit.rb
csview.rb
csvmarker.rb
fzf.rb
ged.rb
gitadd.rb
hashfile.rb
helprb.rb
histoplot.rb
keyhex.rb
move2date.rb
narrate.rb
price.rb
println.rb
puts_methods.rb
rifzf
safe_eval.rb
tabulatedd.rb
wordwrap.rb]

Gem::Specification.new do |s|
  s.name = 'rubytools'
  s.version = '0.0.1'
  s.date = '2020-12-12'
  s.summary = "rubytools - common use libraries and bins"
  s.authors = ["xxanon"]
  s.email = "ironald@gmail.com"
  s.files = files
  s.executables += bins
  s.homepage = "https://github.com/nonnax/rubytools.git"
  s.license = "GPL-3.0"
end

