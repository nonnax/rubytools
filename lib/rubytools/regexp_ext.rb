#!/usr/bin/env ruby
# Id$ nonnax 2022-03-02 11:38:47 +0800
module RegexpExt

  refine Regexp do
    # string regexp helpers
    def to_regexp(mode='i')
      Regexp.new(self, mode)
    end

    def regexp_escape
      Regexp.escape(self)
    end
    alias re regexp_escape
    
  end

end

# String.include(RegexpExt)
# Regexp.include(RegexpExt)
