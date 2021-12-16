#!/usr/bin/env ruby
# Id$ nonnax 2021-12-16 14:28:13 +0800
lib = File.expand_path('lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |s|
  s.name = 'rubytools'
  s.version = '0.0.1'
  s.date = '2020-12-12'
  s.summary = "rubytools - common use libraries and bins"
  s.authors = ["xxanon"]
  s.email = "ironald@gmail.com"
  s.files = `git ls-files`.split("\n") - %w[bin]
  s.executables += `git ls-files bin`.split("\n").map{|e| File.basename(e)}
  s.homepage = "https://github.com/nonnax/rubytools.git"
  s.license = "GPL-3.0"
end

