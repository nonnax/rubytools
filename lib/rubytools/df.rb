#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2022-11-17 17:49:10
$LOAD_PATH<<'.'

require 'forwardable'

class DF
  # dataframe
  # @rows -> [
    # row0 -> [*items],
    # row1 -> [*items],
    # row2 -> [*items],
    # row3 -> [*items]
  # ]
  # @rows.map(&:size).uniq==1 or raise ExceptionDifferentSizes
  # def <<(arow)
  #   raise ExceptionDifferentSizes unless [arow.size, rows.first.size].uniq==1
  #   @rows << arow
  # end

  extend Forwardable
  def_delegators :@rows, :each, :map, :values_at
  # first row determines the size
  attr_accessor :rows

  def initialize(rowsize = 0, truncate: true)
    @rows = [] #Array.new(rowsize) { nil }
    @row_size = rowsize
    @truncate = truncate
  end

  def check_size(row)
    diff = @row_size - row.size
    if diff.positive? # pad with nils if @row_size is bigger
      row + ([nil] * diff)
    elsif diff.negative?
      # truncate rightmost row items if @row_size is smaller
      row[0..@row_size - 1]
    else
      row
    end
  end

  def <<(row)
    row = check_size(row) if @truncate
    raise "Different size: row array size should be #{@row_size}" unless [row.size, @row_size].uniq.size==1

    @rows << row
  end

  def transpose
    df = DF.new(@rows.transpose.first.size)
    @rows.transpose.each do |r|
      df << r
    end
    df
  end

  def to_s(**params)
    # @rows.to_table(**params)
    @rows.map do |r|
      just=params.fetch(:rjust, nil) ? :rjust : :ljust
      v=params.fetch(just, 1)
      # apply formatting to each element
      r.map(&:to_s)
       .map{|s| s.send(just, v)}
       .join(params.fetch(:delimiter, '  '))
    end
    .join("\n")
  end
end
