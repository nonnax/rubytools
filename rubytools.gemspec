#!/usr/bin/env ruby
# Id$ nonnax 2021-12-16 14:28:13 +0800
lib = File.expand_path('lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
files=%w[lib/rubytools.rb
rubytools.gemspec
lib/rubytools/ansi_color.rb
lib/rubytools/array_ext.rb
lib/rubytools/array_table.rb
lib/rubytools/arraycsv.rb
lib/rubytools/asciiplot.rb
lib/rubytools/cache.rb
lib/rubytools/coingecko_price.rb
lib/rubytools/console_ext.rb
lib/rubytools/core_ext.rb
lib/rubytools/cubadoo.rb
lib/rubytools/editor.rb
lib/rubytools/file_ext.rb
lib/rubytools/fzf.rb
lib/rubytools/hash_ext.rb
lib/rubytools/keyboard.rb
lib/rubytools/methods_view.rb
lib/rubytools/numeric_ext.rb
lib/rubytools/pipe_argv.rb
lib/rubytools/scooby.rb
lib/rubytools/string_bars.rb
lib/rubytools/string_ext.rb
lib/rubytools/thread_ext.rb
lib/rubytools/time_and_date_ext.rb
lib/rubytools/xxhsum.rb]

bins=%w[catcsv.rb
coingecko.rb
console.rb
csvedit.rb
csview.rb
csvmarker.rb
ged
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

