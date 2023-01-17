#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2023-01-13 10:52:55
require 'rubytools/core_ext'
require 'math/math_ext'
using MathExt

module Scrapemathics
  include MathExt

  refine String do
    def scan_to_f(re = /[\d.,]+/)
      scan(re).map { |n| n.tr ',', '' }.map(&:to_f)
    end
  end

  refine Array do
    def pair_describe
      first_last.then do |pair|
        pair_delta = pair.then { |d| [[d, d.to_percent_change]].to_h }
        p pair_means = pair.means.map{|e| e.human.to_f}.uniq
        pair_mean_delta = pair.means.each_cons(2).map do |d|
          [[d.map do |e|
              e.human(9).to_f
            end, d.to_delta.to_percent.human.to_f]].to_h
        end
        pair_means_h = { mean: pair_means.mean.human.to_f }
        [pair_means_h, pair_delta, pair_mean_delta].flatten.inject(&:merge).transform_keys(&:inspect).reject{|k, v| v.zero?}

      end
    end
  end
end
