#!/usr/bin/env ruby
# Id$ nonnax 2022-09-09 23:19:26
# require 'rubytools/array_grep'
# using ArrayGrep
require 'json'

module ArrayGrep
  refine Array do
    def self.read(f)
      new.read(f)
    end
    def read(f)
      self.replace JSON.parse File.read(f), symbolize_names: true
    end
    def grep_any(**q, &block)
      grep_h(scope: :any?, **q, &block)
    end
    def grep_all(**q, &block)
      grep_h(scope: :all?, **q, &block)
    end
    def grep_h(scope: :any?, **q, &block)
      select{|e| q.keys.send(scope){|k| e[k].to_s.match?(q[k]) }}.map(&block)
    end
    def map_slice(*keys, &block)
      map { |h| h.slice(*keys).tap { |hs| block[hs] if block } }
    end
  end
end

