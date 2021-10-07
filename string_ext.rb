# frozen_string_literal: true

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
    slice(0,n)
  end

  def last(n)
    slice(n*-1, size)
  end

  def scroll(slice: 10, repeat: 15)
    (self * repeat)
      .split(//)
      .each_cons(slice)
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

module TextScanner
  RE_SENTENCE = /[^.?!]+(?:[.?!])(?:[)"]?)/.freeze
	# RE_SENTENCE = Regexp.new "^\s+[a-zA-Z\s]+[.?!]$"
  def sentences
    gsub!(/\n/, ' ')
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

String.include(TextScanner)
