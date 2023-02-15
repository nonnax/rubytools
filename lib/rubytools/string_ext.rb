#!/usr/bin/env ruby
# frozen_string_literal: true

require 'erb'
require 'base64'
require 'cgi'
require 'rubytools/regexp_ext'
require 'rubytools/xxh_sum'

module StringExt
  refine String do
    def wrap(max_width = 20)
      if size < max_width
        self
      else
        scan(/.{1,#{max_width}}(?: |$)/)
          .join("\n")
      end
    end

    def scroll(slice: 10, repeat: 15)
      take_cons(slice: slice, repeat: repeat)
        .to_a
        .each { |e| yield e.join }
      self
    end

    def take_cons(slice: 10, repeat: 15)
      (self * repeat)
        .split(//)
        .each_cons(slice)
    end

    def gsub_match(re, &block)
      # a more ruby-ish gsub which yields the matched data to the block
      gsub(re) do |_m|
        block&.call(Regexp.last_match)
      end
    end

    def rtrim(len)
      self[0..len-1]
    end


    def render(binding_obj)
      ERB.new(self).result(binding_obj)
    end
    alias result render

    def encode64
      Base64.encode64(self)
    end
    alias to_base64 encode64
    
    def decode64
      Base64.decode64(self)
    end

    def base64?
      Base64.encode64(Base64.decode64(self)).strip == strip && (size % 4).positive?
    end

    def xor(key)
      dup
      .tap{ |text|
        text
        .length
        .times {|n| text[n] = (text[n].ord ^ key[n.modulo key.size].ord).chr }
      }
    end
    
    def to_hexdigest
      Digest::SHA256.hexdigest(self)
    end
  end
end

module QueryStringConverter
  def query_string_to_h
    CGI.parse(URI.parse(self).query).transform_keys(&:to_sym)
  end
end

module TextScanner
  RE_SENTENCE ||= /\b[^.;?!]+(?:[.;?!]|$)(?:[)'"]?)/.freeze # '

  def join!
    gsub!(/\n/, ' ')
  end

  def sentences
    gsub!(/\n{1,}/, ' ')
    keys = %w[“ ” ‘ ’]
    vals = %w[" " ' ']
    to_tr = keys.zip(vals).to_h
    to_tr.each { |k, v| tr!(k, v) }

    scan(RE_SENTENCE).map
  end

  def paragraphs
    split(/\n{2,}/).map
  end

  def sentences_split(arg = /\n/)
    gsub(/([.?!]+)(?=[^'"])/) { |m| "#{m.strip}\n" }.split(arg) # '
  end
end


StringExt.include(TextScanner)
StringExt.include(QueryStringConverter)
StringExt.include(RegexpExt)
StringExt.include(XXHSum)
# String.include(RenderERB)
# String.include(StringBase64)
# String.include(StringXOR)
