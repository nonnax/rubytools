#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2022-11-26 08:57:35
# require 'df/array_df_view'
# using NestedArrayExt
# ...
# df=[]
# def add_rows(n); Array.new(n){rand(10..100_00)} end
# df<<add_rows(15)
# df<<add_rows(15)
# df<<add_rows(15)
# df<<add_rows(15)
#
# df.puts
#
require 'delegate'
#
# module DFArrayExt
  # refine Array do
    # def to_s(**params, &block)
      # with_index=params.fetch(:with_index, false)
      # separator=params.fetch(:separator, ' ')
      # df = Marshal.load(Marshal.dump(self)) # do not mutate original df
      # max_col_size=df.map(&:size).max
      # df.map!{|r|
        # padding=[nil]*(max_col_size-r.size)
        # r+padding
      # }
      # if with_index # with_index add col numbers
        # df.prepend((1..df.first.size).to_a)
        # df=df.map.with_index{|r, i| r.prepend(i)}
      # end
      # maxwidths = df.transpose.map { |r| r.map(&:to_s).map(&:size).max }
#
      # df
        # .map do |row|
          # row
           # .map(&:to_s)
           # .map.with_index { |s, i| s.rjust(maxwidths[i]) }
        # end
        # .map { |r| r.join(separator) }
        # .join("\n")
        # .tap { |s| block.call(s) if block }
    # end
  # end
# end

class DFPuts < SimpleDelegator
    def to_s(**params, &block)
      with_index=params.fetch(:index, false)
      separator=params.fetch(:separator, ' ')
      df = Marshal.load(Marshal.dump(self)) # do not mutate original df
      max_col_size=df.map(&:size).max
      df.map!{|r|
        padding=[nil]*(max_col_size-r.size)
        r+padding
      }
      if with_index # with_index add col numbers
        df.prepend((1..df.first.size).to_a)
        df=df.map.with_index{|r, i| r.prepend(i)}
      end
      maxwidths = df.transpose.map { |r| r.map(&:to_s).map(&:size).max }

      df
        .map do |row|
          row
           .map(&:to_s)
           .map.with_index { |s, i| s.rjust(maxwidths[i]) }
        end
        .map { |r| r.join(separator) }
        .join("\n")
        .tap { |s| block.call(s) if block }
    end
    def puts(**params, &block)
      Kernel.puts to_s(**params, &block)
    end
end
