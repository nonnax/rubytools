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
    @cols = df.map(&:size).max unless @cols
    df.each {|row| self << row }
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

  def diff(another, **params, &block)
    prefix=params.fetch(:prefix, '\\')
    b = another.to_a
    DF.new {
      self
      .to_a
      .map
      .with_index do |r, i|
        r.map.with_index do |v, j|
          bv = b[i][j]
          cond = block&.call(v, bv) || v != bv
          cond ? "#{prefix}#{v}" : v
        end
      end
    }
  end

  def to_s(**params, &block)
    view_rows=@rows.dup

    col_widths = @rows.dup.transpose.map { |r| r.map(&:to_s).map(&:size).max }
    fixed_width = params.fetch(:width, nil)
    header = params.fetch(:header, nil)
    view_rows.prepend(view_rows.first.size.times.map.to_a) if header
    col_widths.map! { fixed_width } if fixed_width

    view_rows
    .map do |r|
      just = params[:ljust] ? :ljust : :rjust
      # apply formatting to each element
      r.map(&:to_s)
       .map.with_index { |s, i| s.send(just, col_widths[i]) }
       .join(params.fetch(:separator, '  '))
     end
    .join("\n")
    .tap { |s| block&.call(s) }
  end
end

class DF
 def rc(row, col, index_by: 1)
   # row, col = [row, col].map{|e| e-1} if index_by.positive?
   row, col = [row.clamp(0, rows.size-1), col.clamp(0, rows.first.size-1)]
   rows[row][col].dup
 end
 def [](*cols, &block)
   # select columns and apply a function on them
   # return a new DF result
   DF.new do
    rows.map.with_index do |r, i|
      [r, block.call(*cols.map{|col| rc(i, col)})].flatten
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
           .then { |df| df.transpose}
  end
end

# require 'rubytools/numeric_ext'
# using NumericExt
