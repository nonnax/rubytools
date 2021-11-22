# frozen_string_literal: true

# core_ext.rb duplicated
# class String
  # def wrap(max_width = 20)
    # if length < max_width
      # self
    # else
      # scan(/.{1,#{max_width}}(?: |$)/).join("\n")
    # end
  # end
# end
require 'erb'

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
  
end

module QueryStringConverter
  def to_h
    u,q=split('?')
    v=q
      .split(/&/)
      .inject({}) do |h, pair|
        k, v=pair.split('=')
        v=v.split(',') if v.match(/,/)
        h[k.to_sym]=v
        h
      end
    {}.merge(u=>v)
  end
end

module TextScanner
  RE_SENTENCE ||= /[^.;?!]+(?:[.;?!]|$)(?:[)"]?)/.freeze
  # "

  def joined
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
end

module SafeFileName
  def to_safename
    gsub(/[^\w\.]/, '_')
  end
end

module RenderERB
  def render(binding_obj)
    ERB.new(self).result(binding_obj)
  end
end

String.include(TextScanner)
String.include(SafeFileName)
String.include(QueryStringConverter)
String.include(RenderERB)
