#!/usr/bin/env ruby
# Id$ nonnax 2022-11-30 10:03:21

# using NThreadsExt
# usage:
# q=1500.thread_queues
# 16.thread_pools{
  # xprocess(q.pop()) until q.empty?
# }
# or single method call
# 16.thread_pools(queue: 1500){|q|
  # xprocess(q.pop()) until q.empty?
# }

module NThreadsExt
  refine Integer do
    def thread_pools(queue:1, &block)
      q=queue.thread_queues
      qblock=->{
        block.call(q)
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
