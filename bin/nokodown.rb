#!/usr/bin/env ruby
# Id$ nonnax 2023-01-06 12:31:57
require 'rubytools/noko_party'
u, = ARGV
f = [File.basename(u, '.*'), 'html'].join('.')
File.write f, NokoParty.get(u)
