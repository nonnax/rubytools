#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2023-01-11 22:41:45
# beep -f 4500 -l50 -d40 -r3 -n -f 2600 -d70 -r3 -l50
class Beeper
  def initialize(&block)
    @beeps = []
    instance_eval(&block) if block
  end

  def push(freq: 4500, len: 50, del: 10, rep: 2)
    @beeps << { freq:, len:, del:, rep: }
  end

  def empty?
    @beeps.empty?
  end

  def beep(&block)
    @beeps
      .inject([]) do |acc, h|
      acc << format('-f %<freq>s -l %<len>s -d %<del>s -r %<rep>s', h)
    end
      .join(' -n ')
      .then { |s| ['beep ', s].join }
      .tap { |s| block&.call(s) }
      .then { |s| IO.popen(s, &:read) }
  end

  def self.beep(fq = nil, freq: 4500, len: 50, del: 10, rep: 1)
    freq = fq if fq
    obj = new
    obj.push(freq:, len:, del:, rep:) if obj.empty?
    obj.beep
  end
end
