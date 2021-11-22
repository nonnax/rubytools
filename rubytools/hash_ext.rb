#!/usr/bin/env ruby
# Id$ nonnax 2021-11-16 10:11:27 +0800
require 'cgi'
require 'uri'

class Hash
  def to_query_string
    inject([]) do |a, (k, v)|
      if v.is_a?(Hash)
        v=v.to_query_string 
      elsif v.is_a?(Array)
        v=v.join(',')
      end
      a<<[k, v].join('=')
    end.join('&')
  end
end

class String
  def query_string_to_h
    CGI.parse(URI.parse(self).query).transform_keys(&:to_sym)
  end
end
