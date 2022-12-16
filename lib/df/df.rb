#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2022-11-17 17:49:10
require 'forwardable'
require 'delegate'
require 'df/df_ext'
using DFExt

module ArrayMarshalExt
  refine Array do
    def deep_dup
      Marshal.load(Marshal.dump(self))
    end
    def and(other_arr, &block)
      self.map.with_index{|e, i| block.call(*[e, other_arr[i]]) }
    end
  end
end

using ArrayMarshalExt

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

  def to_a
    @rows.deep_dup
  end

  def +(another_df)
    DF.new{ @rows.to_a+another_df.to_a }
  end

  def <<(row)
    row = check_size(row)
    raise "Different column size: should be #{@cols}" unless [row.size, @cols].uniq.size == 1

    @rows << row
    self
  end

  def prepend(row)
    row = check_size(row)
    raise "Different column size: should be #{@cols}" unless [row.size, @cols].uniq.size == 1

    @rows.prepend row
    self
  end

  def define(&block)
      @rows
      .deep_dup
      .tap(&block)
      .then{|arr|
        DF.new{arr}
      }
  end

  def no_headers
    columns=[]
    [define{|o| columns<<o.shift}, {columns: columns.flatten}]
  end

  def no_indexes
    rows=[]
    [define{|o| rows<<o.map(&:shift) }, {rows: rows.flatten}]
  end

  def at_columns(*cols)
   self
   .deep_dup
   .transpose
   .define{|o| o.replace o.values_at(*cols)}
   .transpose
  end

  def transpose
    DF.new { @rows.transpose }
  end


  def to_s(**params, &block)
    view_rows = @rows.deep_dup

    _columns=(1..view_rows.first.size).to_a.zip([]+Array(params[:columns])).to_h
    _rows=(0..view_rows.size).to_a.zip(%w[-]+Array(params[:rows])).to_h

    fixed_width = params.fetch(:width, nil)
    separator = params.fetch(:separator, '  ')
    just = params[:ljust] ? :ljust : :rjust

    if params.fetch(:index, nil)
      view_rows.prepend(_columns.map{|k, v| v || k }) # column labels
      view_rows=view_rows.map.with_index{|r, i|r.prepend( _rows[i] || i) } # row labels
    end

    view_rows.to_table(width: fixed_width)
  end

  def deep_dup
    Marshal.load(Marshal.dump(self))
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

  def rc(row, col, index: 1)
    row = row.clamp(-rows.size, rows.size - 1)
    col = col.clamp(-rows.first.size, rows.first.size - 1)
    rows[row][col].dup
  end

  def [](*cols, &block)
    # select columns and apply a function on them
    # return a new DF result
    DF.new do
      rows
      .map
      .with_index do |r, i|
        [r, block.call(*cols.map { |col| rc(i, col) })].flatten
      end
    end
  end

end

class DF
 def arrange(*columns, **params)
  # columns are 1-indexed by default
   index = params.fetch(:index, 1)
   columns=columns.uniq
   fail "columns size do not match #{[columns.size, @rows.first.size]}" unless [columns.size, @rows.first.size].uniq.size==1
   @rows.map{|r|
    r.map.with_index{|e, i|
     idx = index==1 ? columns[i].pred : columns[i]
     r[idx]
    }
   }
   .then{|arr| DF.new{arr}}
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
