#!/usr/bin/env ruby
require 'erb'

desc = ARGV.join(' ')
gemname= Dir.pwd.rpartition('/').last
desc ||= gemname
puts ERB.new( DATA.read).result(binding)

__END__
Gem::Specification.new do |s|
  s.name = '<%= gemname%>'
  s.version = '0.0.1'
  s.date = '<%= Time.now.strftime('%Y-%m-%d') %>'
  s.summary = "<%= desc%>"
  s.authors = ["xxanon"]
  s.email = "ironald@gmail.com"
  s.files = `git ls-files`.split("\n") - %w[bin misc]
  s.executables += `git ls-files bin`.split("\n").map{|e| File.basename(e)}
  s.homepage = "https://github.com/nonnax/<%= gemname%>.git"
  s.license = "GPL-3.0"
end

---------cut-----------
# Gemfile

source "https://rubygems.org"

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


# gem '<%= gemname%>', :github => 'nonnax/<%= gemname%>'
