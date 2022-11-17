#!/usr/bin/env ruby
task default: %w[build]

desc "Bundle install dependencies"
task :bundle do
  sh "bundle install"
end

desc "Build the rubytools.gem file"
task :build do
  sh "gem build rubytools.gemspec"
end

desc "install rubytools-x.x.x.gem"
task :install do
  sh "gem install $(ls rubytools-*.gem)"
end
