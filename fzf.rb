# frozen_string_literal: true

module Enumerable
  def fzf
    IO.popen('fzf -m', 'w+') do |io| 
      io
        .puts to_a.join("\n")
      io
        .read
        .split("\n") 
    end
  end

  def fzf_with_index
    IO.popen('fzf -m', 'w+') do |io|
      io.puts to_a
                .map
                .with_index { |e, i| [i, e].join("\t") }
                .join("\n")
      # return integer indices 
      io.read
        .split("\n")
        .map{|e| e.split(/\s/, 2)}
        .map { |i, e| [i.to_i, e] }
    end
  end
end


if __FILE__==$0 then
  p Dir['*.*'].fzf
  p Dir['*.*'].fzf_with_index
  p (1..100).fzf
  p 'v = (rand(100..200)..200).fzf'
  p v = (rand(100..200)..200).fzf
  p 'v = (rand(100..200)..200).to_a.fzf_with_index'
  p v = (rand(100..200)..200).to_a.fzf_with_index
end
