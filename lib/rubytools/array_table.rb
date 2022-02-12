#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2021-09-18 17:23:18 +0800

# df = [] 
#
# 10.times do
#   df << Array.new(5) { rand(100_000).to_f }
# end
# 
# renders a dataframe into table
#
# puts df.to_table(delimeter: ' / ',	rjust: [0, 1, 2], ljust: (3..5))
# or
# df.to_table(delimeter: ' / ',	rjust: [0, 1, 2], ljust: (3..5)) do |row|
#   puts row.reverse
# end
#

class Array

  def safe_transpose
    pad_rows.to_a.transpose
  end

  def sum_columns
    transpose.map do |col|
      col<<col.map{|e| e.nil? ? 0 : e}.sum rescue [0]*col.size
    end.transpose
  end

  def to_table(df = self, **h, &block)
    # renders a dataframe into table
    align_keys = %i[ljust rjust center]
    delimeter = h[:delimeter] || ' | '
    unless (align_keys & h.keys).empty?
      align_method, selected_columns = h.select { |k, _| align_keys.include?(k) }.to_a.first
    end
    # column widths
    column_width = {}
    df.first.size.times { |i| column_width[i] = 0 }

    # detect max width and init column widths
    df.dup.transpose.each_with_index do |e, i|
      column_width[i] = e.map(&:to_s).map(&:size).max
    end
    # all table items become strings
    # column widths are adjusted to max widths
    prep = df.transpose.map.with_index do |r, i|
      r.map(&:to_s).map { |e| e.to_s.rjust(column_width[i]) }
    end
    # adjust specific cols selected
    # selected_columns=(0..df.first.size)
    # align_method = :center
    # align_method = :rjust
    #
    if align_method
      prep = prep.map.with_index do |r, i|
        r.map! { |e| selected_columns.include?(i) ? e.strip.send(align_method, column_width[i]) : e } 
        r
      end
    end

    prep.transpose.map do |r|
      if block_given?
        block.call(r) 
      else
        r.join(delimeter)
      end
    end #.join("\n")
  end

  #helper methods

  def each_slice_safe(n, padding: nil)
    # returns equally sliced rows
    # padded with <padding>
    # returns an Enumerator
    arr=each_slice(n).to_a
    arr.pad_rows(padding:)
  end

  def pad_rows(padding:nil)
    # returns equally resized rows
    # returns an Enumerator
    max_size=map(&:size).max
    dup.map do |d|
      d + [padding] * (max_size - d.size)
    end.map
  end
  alias auto_resize_rows pad_rows

end

require 'csv'

class String
  def view_as_table(delimeter:'  ' , col_sep: ",")
    data=CSV.parse(self, converters: :numeric, col_sep:)
    data
      .pad_rows
      .to_a    
      .to_table(delimeter:)
  end
end

if __FILE__ == $PROGRAM_NAME
  # require 'numeric_ext'
  df = []

  10.times do
    df << Array.new(5) { '#' * rand(10) }
  end

  10.times do
    df << Array.new(5) { rand(100_000).to_f }
  end

  puts df.to_table(rjust: (0..df.first.size), delimeter: ' ' * 3)

  # puts '-'*100
  #
  puts df.to_table(delimeter: ' / ',	rjust: [0, 1, 2])
end
