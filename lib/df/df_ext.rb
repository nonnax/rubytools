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

    def to_balanced_array
      maxlen=self.longest_row
      self
      .deep_dup
      .map{|r| r.rjust(maxlen) }
      .map{|r| r.flatten }
    end

    def to_hash
      self
      .to_balanced_array
      .inject({}){ |h, r| h[r.shift] = r; h}
    end

    def max_column_widths
      self
      .deep_dup
      .to_balanced_array
      .map{|r| r.map(&:to_s).map(&:size).max }
    end

    def to_table
      widths=max_column_widths

      self
      .deep_dup
      .to_balanced_array
      .map
      .with_index{|r, i|
        r.map{|e| e.to_s.rjust(widths[i], ' ')}
      }
      .transpose
      .map{|r| r.join(' ')}
      .join("\n")
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
      .to_balanced_array
      .inject({}){ |h, r| h[r.shift] = r; h}
    end

    def to_balanced_array
      self
      .dup
      .to_flat_array
      .to_balanced_array
    end

    def transpose
      self
      .to_flat_array
      .to_balanced_array
      .transpose
      .to_hash
    end

  end
end

module DFExt
  include ArrayExt
  include HashExt
end
