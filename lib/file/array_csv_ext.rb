#!/usr/bin/env ruby
# Id$ nonnax 2023-04-09 14:58:18 +0800
require 'file/filer'

module ArrayCSVExt
 refine Array do
  def Array.read_csv(f)
   f, data = Filer.load_csv(f){{}}
   data.map(&:values).prepend(data.first.keys)
  end
  def write(f)
    Filer.write_csv(f, self)
  end
 end
end
