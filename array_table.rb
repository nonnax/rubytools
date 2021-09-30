#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2021-09-18 17:23:18 +0800

class Array
  def safe_each_slice(n)
    # yields evenly sliced sub-arrays; padded with nils
    each_slice(n)
      .to_a
      .tap do |d|
      d[-1] += [nil] * (d.first.size - d.last.size)
    end.to_enum
  end

  def row_padding(with: nil)
    # yields evenly padded rows
    # [[1, 2, 3], [1], [1, 2]].row_padding(with: 0) == [[1, 2, 3], [1, 0, 0], [1, 2, 0]]
    max_size=map(&:size).max 
    map do |e|
      e += [with] * (max_size - e.size)
    end#.to_enum
  end

  def safe_transpose
    # pad last with nils for transpose
    dup.tap do |d|
      d[-1] += [nil] * (d.first.size - d.last.size)
    end.transpose
  end

  def sum_columns
  	transpose.map do |col|
  		col<<col.map{|e| e.nil? ? 0 : e}.sum rescue [0]*col.size
  	end.transpose
  end

  def to_table(df = self, **h, &block)
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
        r.map! { |e| e.strip.send(align_method, column_width[i]) } if selected_columns.include?(i)
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
