#!/usr/bin/env ruby
# Id$ nonnax 2021-11-30 00:16:10 +0800
module XXHSum
  def xxhsum(h: 64)
    IO.popen("xxhsum -H#{h}", "w+") do |io| 
      io.puts self 
      io.close_write 
      io.read
    end.split(/\s+/).first
  end
  def xxh32sum()
      xxhsum(h: 32)
  end

end

String.include(XXHSum)
