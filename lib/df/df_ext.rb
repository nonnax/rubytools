#!/usr/bin/env ruby
# Id$ nonnax 2022-12-05 15:35:08

module ArrayExt
  refine Array do

    def deep_dup
      Marshal.load(Marshal.dump(self))
    end

    def rjust(adjust, padding=nil)
      self.dup.then{|arr|
        arr+([padding]*(adjust-arr.size))
      }
    end

    def longest_row
      self.map(&:size).max
    end

    def balanced_rows
      maxlen=self.longest_row
      self
      .map{|r| r.rjust(maxlen) }
      .map{|r| r.flatten }
      .then{|a| a.deep_dup }
    end

    def to_hash
      self
      .balanced_rows
      .inject({}){ |h, r| h[r.shift] = r; h}
    end

  end
end

module HashExt
  using ArrayExt

  refine Hash do

    def to_flat_array
      self.map{ |h| h.flatten }
    end

    def to_balanced_hash
      self
      .to_flat_array
      .balanced_rows
      .inject({}){ |h, r| h[r.shift] = r; h}
    end

    def transpose
      self
      .to_flat_array
      .balanced_rows
      .transpose
      .to_hash
    end

  end
end

module DFExt
  include ArrayExt
  include HashExt
end
