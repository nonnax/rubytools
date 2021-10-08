# frozen_string_literal: true

require 'json'

module Enumerable
  def fzf(cmd: 'fzf -m')
    IO.popen(cmd, 'w+') do |io|
      io
        .puts to_a.join("\n")
      io
        .read
        .split("\n")
    end
  end

  def fzf_with_index(cmd: 'fzf -m', &block)
    IO.popen(cmd, 'w+') do |io|
      io
        .puts to_a
        .map
        .with_index{ |e, i|
        e = block.call(e) if block_given?

        [i, e.to_json].join("\t")
       }
       .join("\n")
      # return integer indices
      io.read
        .split("\n")
        .map { |e| e.split(/\s/, 2) }
        .map { |i, e| [i.to_i, e] }
    end
  end

  def fzf_map(cmd: 'fzf -m')
    IO.popen(cmd, 'w+') do |io|
      io
        .puts to_a
        .map{ |k, v|
        [k, v.split("\n").join(' ~ ')]
          .join(' : ')
      	}
      	.join("\n")
      io
        .read
        .split("\n")
        .map { |h| h.split(/\s?:\s?/, 2) }
        .map { |i, e| [i.to_sym, e] }
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  p Dir['*.*'].fzf
  p Dir['*.*'].fzf_with_index
  p (1..100).fzf
  p 'v = (rand(100..200)..200).fzf'
  p v = (rand(100..200)..200).fzf
  p 'v = (rand(100..200)..200).to_a.fzf_with_index'
  p v = (rand(100..200)..200).to_a.fzf_with_index
  h = { name: 'ronald', hobby: 'noodling' }
  p h.fzf_map
end
