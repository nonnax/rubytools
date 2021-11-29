#!/usr/bin/env ruby
# Id$ nonnax 2021-11-16 10:11:27 +0800
require 'cgi'
require 'uri'

class Hash
  def to_query_string(repeat_keys: false)
     repeat_keys ? send(:_repeat_keys) : send(:_single_keys)
  end
  
  def _single_keys
    inject([]) do |a, (k, v)|
      if v.is_a?(Hash)
        v=v._single_keys
      elsif v.is_a?(Array)
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

class String
  def query_string_to_h
    CGI.parse(URI.parse(self).query).transform_keys(&:to_sym)
  end
end
