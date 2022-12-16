#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2022-12-05 15:35:08

module ArrayExt
  refine Array do
    def deep_dup
      Marshal.load(Marshal.dump(self))
    end

    def ljust(adjust, padding = nil)
      dup.then do |arr|
        arr + ([padding] * (adjust - arr.size))
      end
    end

    def longest_row
      map(&:size).max
    end

    def to_balanced_array
      maxlen = longest_row

      deep_dup
        .map { |r| r.ljust(maxlen) }
        .map(&:flatten)
    end

    def to_hash
      to_balanced_array.each_with_object({}) do |r, h|
        h[r.shift] = r
      end
    end

    def max_column_widths
      deep_dup
        .to_balanced_array
        .map { |r| r.map(&:to_s).map(&:size).max }
    end

    def map_as_strings(&block)
      deep_dup
        .map
        .with_index do |r, i|
          block ? block.call(r.map(&:to_s), i) : r
        end
    end

    def to_table(separator: ' ', width: nil)
      widths = width ? max_column_widths.map{ width } : max_column_widths

      deep_dup
        .to_balanced_array
        .map
        .with_index do |r, i|
          r.map { |e| e.to_s.rjust(widths[i], ' ') }
        end
        .transpose
        .map { |r| r.join(separator) }
        .join("\n")
    end
  end
end

module HashExt
  using ArrayExt

  refine Hash do
    def to_flat_array
      map(&:flatten)
    end

    def to_balanced_hash
      to_flat_array
        .to_balanced_array
        .each_with_object({}) do |r, h|
          h[r.shift] = r
        end
    end

    def to_balanced_array
      dup
        .to_flat_array
        .to_balanced_array
    end

    def transpose
      to_flat_array
        .to_balanced_array
        .transpose
        .to_hash
    end
  end
end

module DFExt
  include ArrayExt
  include HashExt
end
