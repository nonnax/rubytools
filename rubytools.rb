#!/usr/bin/env ruby
# Id$ nonnax 2021-11-22 09:59:02 +0800
# IMPORTANT: 
# the required <filename> and underlying <libname> must be the same.
# make links to rubytools.rb and rubytools dir into same $LOAD_PATH
#
# USAGE:
# require 'rubytools' #on top 
# require <tool>, ie. 'fzf'
# HELP: 
# use rubytools() to list <tools>

libdir = [File.expand_path(File.dirname(__FILE__)), File.basename(__FILE__, '.rb')].join('/')
$LOAD_PATH.prepend(libdir) unless $LOAD_PATH.include?(libdir)

def rubytools
  Dir[File.join(__dir__, 'rubytools', '*.rb')]
end
