#!/usr/bin/env ruby
# Id$ nonnax 2022-03-02 11:38:47 +0800
module RegexpExt
  # string regexp helpers
  def to_regexp
    Regexp.new(self)
  end
  def regexp_escape
    Regexp.escape(self)
  end
  alias re regexp_escape
end

String.include(RegexpExt)
Regexp.include(RegexpExt)
