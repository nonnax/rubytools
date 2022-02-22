#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2021-09-18 17:23:18 +0800

# df = [] 
#
# 10.times do
#   df << Array.new(5) { rand(100_000).to_f }
# end
# 
# renders a dataframe into string formatted table
#
# puts df.to_table(delimiter: ' / ',	rjust: [0, 1, 2], ljust: (3..5))
#
# a block yields arrays of rendered string elements 
#
# df.to_table(delimiter: ' / ',	rjust: [0, 1, 2], ljust: (3..5)) do |row|
#   puts row.reverse
# end
#
# delimeter: or shortcut delim: 
#

module ArrayTable

  def safe_transpose
    pad_rows.transpose
  end

  def sum_columns
    transpose.map do |col|
      col<<col.map{|e| e.nil? ? 0 : e}.sum rescue [0]*col.size
    end.transpose
  end

  def to_table(df = self, **h, &block)
    # renders a dataframe into table
    # align_method keys = :center, :ljust, :rjust
    # puts df.to_table(delimiter: ' / ',	rjust: [0, 1, 2], ljust: (3..5))
    # ...
    # or
    # ...
    # df.to_table(delim: '/',	rjust: [0, 1, 2], ljust: (3..5)) do |row|
    #   puts row.reverse
    # end

    align_keys = %i[ljust rjust center]
    delimiter = h[:delimiter] || h[:delim] || ' | '
    unless (align_keys & h.keys).empty?
      align_method, selected_columns = h.select { |k, _| align_keys.include?(k) }.to_a.first
    end

    # column widths
    column_width = {}
    df.first.size.times { |i| column_width[i] = 0 }

    # detect max width to become fixed column widths
    df.safe_transpose.each_with_index do |e, i|
      column_width[i] = e.map(&:to_s).map(&:size).max
    end

    # all table items become strings
    # column widths are adjusted to max widths
    # short rows are padded/filled
    prep = df.safe_transpose.map.with_index do |r, i|
      r.map(&:to_s).map { |e| e.to_s.rjust(column_width[i]) }
    end
    
    # adjust specific cols selected
    # selected_columns=(0..df.first.size)
    # align_method = :center
    # align_method = :rjust

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
        r.join(delimiter)
      end
    end
  # rescue => e
    # p e
  end

  #helper methods

  def each_slice_safe(n=1, padding: nil)
    # returns equally sliced rows
    # padded with <padding>
    enum=each_slice(n)
    enum
     .pad_rows(padding:)
     .to_enum
  end

  def pad_rows(padding:nil)
    # resizes short rows
    # returns an Array dataframe
    max_size=map(&:size).max
    dup.map do |d|
      d + [padding] * (max_size - d.size)
    end
  end
  alias auto_resize_rows pad_rows
end

Enumerable.include(ArrayTable)

# convenience method for terminal piped strings

require 'csv'

class String
  def view_as_table(delimiter:'  ' , col_sep: ",")
    data=CSV.parse(self, converters: :numeric, col_sep:)
    data
      .to_table(delimiter:)
  end
end

if __FILE__ == $PROGRAM_NAME
  # require 'numeric_ext'
  df = []

  5.times do
    df << Array.new(5) { '#' * rand(10) }
  end

  5.times do
    df << Array.new(5) { rand(100_000).to_f }
  end

  puts '# df.to_table'
  puts df.to_table
  
  puts '# df.to_table(ljust: (1..df.first.size), delimiter:" " * 3)'
  puts df.to_table(ljust: (1..df.first.size), delimiter: ' ' * 3)

  puts '# df.to_table(delim: " / ",	ljust: [0, 1, 2])'
  puts '# delimeter: or shortcut delim:' 
  puts df.to_table(delimiter: ' / ',	ljust: [0, 1, 2])
end
