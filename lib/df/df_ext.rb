#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2022-12-05 15:35:08
require 'math/math_ext'
require 'rubytools/numeric_ext'


module ObjectExt
  refine Object do
    def deep_dup
      Marshal.load(Marshal.dump(self))
    end
  end
end

module ArrayExt
  using ObjectExt

  refine Array do
    def ljust(width=1, padding = nil)
      dup + ([padding] * (width - size))
    end

    def longest_row
      map(&:size).max
    end

    def reshape(width = nil, padding = nil)
      max_width = width || longest_row
      map { |r| r.ljust(max_width, padding) }
    end

    def to_hash
      reshape
      .each_with_object({}) do |r, h|
        h[r.shift] = r
      end
    end

    def max_column_widths
      deep_dup
        .map { |r| r.map(&:to_s).map(&:size).max }
    end

    def map_as_strings(&block)
      deep_dup
        .map do |r|
          r_string = r.map(&:to_s)
          block ? block.call(r_string) : r_string
        end
    end

    def to_table(separator: ' ', width: nil, &block)
      widths = width ? max_column_widths.map{ width } : max_column_widths

      deep_dup
        .reshape
        .map
        .with_index do |r, i|
          r.map { |e| e.to_s.rjust(widths[i], ' ') }
        end
        .transpose
        .map { |r| block ? block.call(r) : r}
        .map { |r| r.join(separator) }
        .join("\n")
    end

    alias to_s to_table

    def except(*rejects)
      reject.with_index{|_e, i| rejects.include?(i) }
    end

    def fill(start, stop, char='x')
      stop=stop.clamp(0..self.size)
      (start...stop).each do |i|
        self[i] = char
      end
      self
    end

    def hashes_to_df
      [first.keys] + map(&:values)
    end

    # def to_html
      # IRuby::HTML.table(self)
    # end

  end
end

module HashExt
  using ArrayExt

  refine Hash do
    def to_flat_array
      map(&:flatten)
    end

    def reshape(width=nil, padding=nil)
      max_width = width || values.longest_row
      dup
        .transform_values{|v| v.ljust(max_width, padding)}
    end

    def transpose
      to_flat_array
        .reshape
        .transpose
        .to_hash
    end

    def to_table
      to_flat_array
        .to_table
    end
  end
end

module DFExt
  include ArrayExt
  include HashExt
  include ObjectExt
  include MathExt
  include NumericExt
end
