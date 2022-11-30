#!/usr/bin/env ruby
# Id$ nonnax 2022-11-30 10:03:21
module NThreadsExt
  refine Integer do
    def threads(queue:1, &block)
      q=queue.thread_queues
      qblock=->{
        until q.empty?
          block.call(q.pop)
        end
      }
      Array.new(self){Thread.new(&qblock)}.map(&:join)
    end
    def thread_queues
      Queue.new.tap{|q|
        self.times{|i| q.push i }
      }
    end
  end
end

require 'delegate'

using NThreadsExt
class ThreadArray<SimpleDelegator
  def map_threads(threads:4, &block)
    threads.threads(queue: self.size) do |q|
      block.call(*self.shift)
    end
  end
end

# using NThreadsExt
# usage:
# q=1500.thread_queues
# 16.threads{
  # xprocess(q.pop()) until q.empty?
# }
# or single method call
# 16.threads(queue: 1500){|q|
  # xprocess(q.pop()) until q.empty?
# }
