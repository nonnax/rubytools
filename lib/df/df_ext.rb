#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2022-12-05 15:35:08

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

    def ljust_rows(width = nil, padding = nil)
      max_width = width || longest_row
      map { |r| r.ljust(max_width, padding) }
    end

    def to_hash
      ljust_rows.each_with_object({}) do |r, h|
        h[r.shift] = r
      end
    end

    def max_column_widths
      deep_dup
        .map { |r| r.map(&:to_s).map(&:size).max }
    end

    def map_as_strings(&block)
      deep_dup
        .map
        .with_index do |r, i|
          r_string = r.map(&:to_s)
          block ? block.call(r_string, i) : r_string
        end
    end

    def to_table(separator: ' ', width: nil)
      widths = width ? max_column_widths.map{ width } : max_column_widths

      deep_dup
        .ljust_rows
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

    def ljust_values(width=nil, padding=nil)
      max_width = width || values.longest_row
      dup
        .transform_values{|v| v.ljust(max_width, padding)}
    end

    def transpose
      to_flat_array
        .ljust_rows
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
end
