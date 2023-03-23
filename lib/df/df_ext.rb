#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2022-12-05 15:35:08
require 'math/math_ext'
# require 'file/filer'

module ObjectExt
  refine Object do
    def deep_dup
      Marshal.load(Marshal.dump(self))
    end
  end
end

module ArrayExt
  using ObjectExt

  refine String do
    def to_a
      self.split(//)
    end
  end

  refine Array do

    # Array#ljust
    # left justify array with `padding` as default value
    #
    def ljust(width=1, padding = nil)
      dup + ([padding] * (width - size))
    end

    # Array#longest_row
    # returns: longest nested array or vector
    def longest_row
      map(&:size).max
    end

    # Array#shape?
    # returns: [rows, cols]
    def shape?
      [size, longest_row]
    end

    # Array#reshape
    # left justify nested arrays with `padding` as default value
    #
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
    alias to_hashes to_hash

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

    def fill!(start, stop, char='x')
      stop=stop.clamp(0..self.size)
      map.with_index do |x, i|
        (start...stop).include?(i) ? char : x
      end
      .then{|arr| self.replace arr}
    end

    def hashes_to_df
      [first.keys] + map(&:values)
    end

    def hashes_to_vectors
      # array of hashes
      # [{:a=>1, :b=>"one"}, {:a=>2, :b=>"two"}, {:a=>3, :b=>"three"}]
      # into a hash of arrays
      # {:a=>[1, 2, 3], :b=>["one", "two", "three"]}
      each_with_object({}) do |h, hacc|
        h.keys.each do |k|
          hacc[k] ||= []
          hacc[k] << h[k]
        end
      end
    end

    # select on keys for matching `where: /regexp/`
    # each value is transformed into a `String` upon matching
    #
    def hashes_select(*keys, where://, &block)
      select { |h| keys.any? { |k| h[k].to_s.match?( Regexp.new(where) ) } }
      .tap { |a| a.map(&block) if block }
    end

    # hash array chainable utils
    def hashes_slice(*keys, &block)
      # select keys on matching re
      map { |h| h.slice(*keys) }
      .tap { |a| a.map(&block) if block }
    end

    # def hashes_merge_000(other, on: nil, left_join: false, lookup_default: nil )
      # raise 'missing param: on' unless on
#
      # on, other_on = on.is_a?(Array) ? on : [on, on]
#
      # lookup = other.group_by{|h| h.delete(other_on) }.transform_values(&:pop)
#
      # hashes = []
      # each do |h|
        # found = lookup[ h[on] ]
        # if found
          # hashes << found.merge(h)
        # else
          # next unless left_join
          # lookup_default ||= other.first.keys.zip(other.first.values.map{ 0 }).to_h
          # hashes << lookup_default.merge(h)
        # end
      # end
      # hashes
    # end

    # hashes_mergez
    # merges an array of hashes on key `on` or `[on, foreign_on]` pair
    # overwrite `orig_val` with `new_val`
    # default is a `hash object` to fill-up unmatched rows
    # otherwise the lookup_default is an `other` element (hash) with 0 (zero) values {key1: 0, ..., key_n : 0}
    def hashes_merge(other, on: nil, left_join: false, default: nil )
      raise 'missing param: on' unless on

      copy, other = [self, other].map{|arr| Marshal.load(Marshal.dump arr)} # prevents mutation on inputs

      on, other_on = on.is_a?(Array) ? on : [on, on]

      other = other.dup.map{|h| h[on]=h.delete(other_on); h}
      lookup = other.group_by{|h| h.fetch(on) }.transform_values(&:pop)
      o_default ||= other.first.dup.transform_values{0}

      merge_keys = (first.keys+other.first.keys).uniq

      # maintain order of orig keys
      copy.each_with_object([]) do |h, arr|
         if found = lookup[ h[on] ]
            h.merge(found) # overwrite `orig_val` with `new_val`
         else
            # orig overwrites blank if `left_join`
            o_default.merge(h) if left_join
         end
         .then do |res|
            arr << res.slice(*merge_keys) if res
         end
      end
    end

    # hashes_join merges an array of hashes on a values of a `on` or `[on, foreign_on]` pair
    # missing values will have default values of nil
    # returns : vectors
    def hashes_join(other, on: nil, left_join:true)
      vectors=Hash.new{|h, k| h[k]=[] }
      indexed = other.to_a.group_by { |r| r.values_at(on) }
      indexed.default = []

      keys=(self.map(&:keys) + other.map(&:keys)).flatten.uniq

      each do |r|
        matches = indexed[r.values_at(on)]
        if matches.empty?
          if left_join
            keys.each do |k|
              vectors[k] << r[k]
            end
          end
        else
          matches.each do |r2|
            keys.each do |k|
              # `other` array overrides orig hash values
              vectors[k] << (r2[k] || r[k])
            end
          end
        end
      end
      vectors
    end

    # def to_html
      # IRuby::HTML.table(self)
    # end

     def strings_to_df
       self.map(&:to_a)
     end

     # overlay_at
     # overlay `another_array` at `index` of original
     def overlay_at(other, idx=0)
      other=other.map
      map.with_index{|x, i|
       (idx...idx+other.size).include?(i) ? other.next : x
      }
     end

   end
end

module HashExt
  using ArrayExt

  refine Hash do
    def to_flat_array
      map(&:flatten)
    end

    def reshape(padding=nil, width=nil)
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

    def to_table(**, &)
      to_flat_array
        .to_table(**, &)
    end

    def each_hash(&block)
      # alternately map column values into df rows
      # the shortest-sized column is used for max iteration count
      # after block for row-wise map operations
      # keys = self.keys if keys.empty?
      shortest=self.values_at(*keys).map(&:size).min
      indexes = (0...shortest.size)
      shortest
      .times
      .map do |outer_i|
         keys.map do |inner_k|
           self[inner_k][outer_i] #? self[k][i] : 0
         end
      end
      .then{|arr| block ? arr.map{|v| block.call(keys.zip(v).to_h) } : arr}
    end

    def vectors_to_df
      even_hash=reshape(padding=0)
      keys=even_hash.keys

      keys
      .map do |k|
        even_hash[k]
      end
      .prepend((1..even_hash.first.last.size).to_a)
      .transpose
      .prepend(['-']+keys)
      .transpose
    end

    def vectors_to_csv_df
        vectors_to_hashes.hashes_to_df
    end

    # vectors to array of hashes
    # yield each hash if block given
    def vectors_to_hashes(&block)
     each_hash{|h| h.values }
     .map{|r|
      keys
      .zip(r)
      .to_h
      .tap{|h| block&.call(h)}
     }
    end

  end
end

module DFExt
  include ArrayExt
  include HashExt
  include ObjectExt
  include MathExt
end

# DF Decorator
# proxy DFExt methods to any DF-compatible object
#
class DDF
 using DFExt

 def initialize(df)
  @df=df
 end

 # pipe for method chaining
 # arguments are methods,
 # methods = [Symbol | Array (to add method arguments)]
 def pipe(*methods)
  methods.reduce(@df){ |df, m|
    m = [m, nil] unless m.is_a?(Array)
    df.send(*m.compact)
  }
 end

 def method_missing(m, *a)
  @df.send(m, *a)
 end

end

# DF(df_obj) candy method
#
module Kernel
  def DF(df)
    DDF.new(df)
  end
end
