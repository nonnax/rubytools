#!/usr/bin/env ruby
# frozen_string_literal: true

# fzf interface
#
require 'json'

module FZF
  def fzf(cmd: 'fzf -m')
    IO.popen(cmd, 'w+') do |io|
      io.puts to_a.join("\n")
      io.close_write
      io.readlines(chomp: true)
    end
  end

  def fzf_prompt(prompt = '> ')
    fzf(cmd: "fzf -m --prompt '#{prompt}'")
  end

  def fzf_query(prompt: '> ', preview: 'echo {}')
    fzf(cmd: "fzf -m --print-query --prompt '#{prompt}' --preview='#{preview} && {q}'")
  end

  def fzf_preview(preview = 'cat {}', cmd: 'fzf -m')
    cmd_arr = []
    cmd_arr << cmd
    cmd_arr << "--preview='#{preview}'"
    fzf(cmd: cmd_arr.join(' '))
  end

  def fzf_with_index(cmd: 'fzf -m', &block)
    IO.popen(cmd, 'w+') do |io|
      io
        .puts to_a
          .map
          .with_index { |e, i|
                e = block.call(e) if block_given?

                [i, e.to_json].join("\t")
              }
        .join("\n")
      io
        .readlines(chomp: true)
        .map { |e| e.split(/\s/, 2) }
        .map { |i, e| [i.to_i, e] }
      # return integer indices
    end
  end

  def fzf_map(cmd: 'fzf -m')
    IO.popen(cmd, 'w+') do |io|
      io
        .puts to_a
          .map { |k, v| [k, v.split("\n").join(' ~ ')].join(' : ') }
        .join("\n")
      io
        .readlines(chomp: true)
        .map { |h| h.split(/\s?:\s?/, 2) }
        .map { |i, e| [i.to_sym, e] }
    end
  end
end

Enumerable.include(FZF)

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
