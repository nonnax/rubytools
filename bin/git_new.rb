#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2021-11-16 14:27:19 +0800
require 'rubytools/string_ext'

repository, = ARGV

username = 'nonnax'
password = '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'
appname = File.basename __FILE__

begin
  raise "usage: #{appname} <repo>" unless repository

  cmds =
    DATA.readlines(chomp: true)
    .reject { |e| e.strip.empty? }
    .map { |l| l.render(binding) }
    .each { |cmd| puts cmd }
    # .each { |cmd| IO.popen cmd, &:read }

rescue StandardError => e
  puts e

end


__END__
curl -u <%= username%>:<%= password%> https://api.github.com/user/repos -d "{\"name\": \"<%= repository %>\"}"

echo "# <%= repository %>" >> README.md
git init
git add .
git commit -m "first commit"
git remote add origin git@github.com:<%= username%>/<%= repository%>.git
git branch -M main
git push -u origin main

