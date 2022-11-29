#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2022-11-17 17:49:10
require 'forwardable'
require 'delegate'

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
  def_delegators :@rows, :each, :map, :values_at, :first, :last
  attr_accessor :rows

  alias to_a rows

  def initialize(cols: nil, &block)
    @rows = []
    @cols = cols
    update(block&.call)
  end

  def check_size(row)
    # return row unless @truncate
    diff = @cols - row.size
    if diff.positive? # pad with nils if @cols is bigger
      row + ([nil] * diff)
    elsif diff.negative?
      # truncate rightmost row items if @cols is smaller
      row[0..@cols - 1]
    else
      row
    end
  end

  def update(df, cols: nil)
    return self unless df

    # widest df column determines the column size unless <cols> is defined

    @rows.clear
    @cols = cols if cols
    @cols ||= df.map(&:size).max
    df.each { |row| self << row }
    self
  end

  def <<(row)
    row = check_size(row)
    raise "Different column size: should be #{@cols}" unless [row.size, @cols].uniq.size == 1

    @rows << row
  end

  def transpose
    DF.new { @rows.transpose }
  end

  def to_s(**params, &block)
    view_rows = @rows.dup

    fixed_width = params.fetch(:width, nil)
    separator = params.fetch(:separator, '  ')
    just = params[:ljust] ? :ljust : :rjust

    view_rows.prepend(view_rows.first.size.times.map.to_a) if params.fetch(:header, nil)

    col_widths = @rows.dup.transpose.map { |r| r.map(&:to_s).map(&:size).max }
    col_widths.map! { fixed_width } if fixed_width


    view_rows
      .map do |r|
      # apply formatting to each element
      r.map(&:to_s)
       .map.with_index { |s, i| s.send(just, col_widths[i]) }
       .join(separator)
    end
      .join("\n")
      .tap { |s| block&.call(s) }
  end
end

class DF
  def diff(another, **params)
    symbols = [-1, 0, 1].zip('<=>'.split(//)).to_h
    symbols.merge!([-1, 0, 1].zip(params[:symbols]).to_h) if params[:symbols]

    width = params.fetch(:width, 2)

    str_just = lambda { |x, dir|
      [x, symbols[dir]].join(' ')
    }
    b = another.to_a
    v = to_a.map.with_index do |r, i|
      r.map.with_index do |v, j|
        bv = b[i][j]
        cond = v <=> bv
        str_just[v, cond]
      end
    end
    DF.new { v }
  end

  def rc(row, col, index_by: 1)
    # row, col = [row, col].map{|e| e-1} if index_by.positive?
    row = row.clamp(0, rows.size - 1)
    col = col.clamp(0, rows.first.size - 1)
    rows[row][col].dup
  end

  def [](*cols, &block)
    # select columns and apply a function on them
    # return a new DF result
    DF.new do
      rows.map.with_index do |r, i|
        [r, block.call(*cols.map { |col| rc(i, col) })].flatten
      end
    end
  end
end

# converts a compatible array into a DF object
class ArrayDF < SimpleDelegator
  def to_df(cols: nil)
    DF.new(cols:) { self }
  end

  def rotate_left
    ArrayDF.new(self).to_df # auto-fill
           .then { |df| ArrayDF.new(df.to_a.map(&:reverse)).to_df }
           .then(&:transpose)
  end
end

# require 'rubytools/numeric_ext'
# using NumericExt
