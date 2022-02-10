#!/usr/bin/env ruby
# Id$ nonnax 2021-11-16 10:11:27 +0800
require 'uri'

module QueryStringHelper
  def to_query_string(repeat_keys: false)
     repeat_keys ? send(:_repeat_keys) : send(:_single_keys)
  end
  
  def _single_keys
    inject([]) do |a, (k, v)|
      case v
        when Hash
          v=v._single_keys
        when Array
          v=v.join(',')
      end
      a<<[k, v].join('=')
    end.join('&')
  end
  private :_single_keys
  
  def _repeat_keys
    URI.encode_www_form(self)
  end
  private :_repeat_keys
  
end

module PrintFormatter
  def format(fmt_str)
    Kernel.format(fmt_str, self)
  end
end

Hash.include(QueryStringHelper)
Hash.include(PrintFormatter)
