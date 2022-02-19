#!/usr/bin/env ruby
# frozen_string_literal: true

require 'erb'
require 'base64'
require 'cgi'

class String
  def wrap(max_width = 20)
    if size < max_width
      self
    else
      scan(/.{1,#{max_width}}(?: |$)/)
        .join("\n")
    end
  end

  def first(n)
    slice(0, n)
  end

  def last(n)
    slice(n * -1, size)
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

  def gsub_match(*a, &block)
    # a more ruby-ish gsub which yields the matched data to the block
    gsub(*a) do |m|
      p m.class
      block&.call(m, Regexp.last_match)
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

module RenderERB
  def render(binding_obj)
    ERB.new(self).result(binding_obj)
  end
  alias result render
end

module StringBase64
  def encode64
    Base64.encode64(self)
  end

  def decode64
    Base64.decode64(self)
  end

  def base64?
    Base64.encode64(Base64.decode64(self)).strip == strip && (size % 4).positive?
  end
end

String.include(TextScanner)
String.include(QueryStringConverter)
String.include(RenderERB)
String.include(StringBase64)
