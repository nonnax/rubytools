#!/usr/bin/env ruby
# Id$ nonnax 2021-11-08 12:50:01 +0800

text=gets
print text+"\t"
print eval( text.gsub(%r{[^\d.+-/*()\[\]]|\,},''))
