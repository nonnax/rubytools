#!/usr/bin/env ruby
# Id$ nonnax 2021-11-30 00:16:10 +0800
module XXHSum
  def xxhsum()
    IO.popen("xxhsum", "w+") do |io| 
      io.puts self 
      io.close_write 
      io.read
    end.split(/\s+/).first
  end
end

String.include(XXHSum)
