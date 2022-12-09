#!/usr/bin/env ruby
# Id$ nonnax 2022-12-09 15:26:35
require 'df/df_ext'
require 'rubytools/ascii_consts'
using DFExt

BOX=DENSITY_SIGNS[-1]

module DFBarChart
 module_function

 def plot(arr, bar: true, &block)
   arr=Marshal.load(Marshal.dump(arr))
   min, max = block ? block.call(arr) : arr.minmax

   row_labels=->arr{
     row_index = (0..arr.first.size-1).to_a.map{ '-' }.reverse
     row_index[0] = max #(max/100.0).ceil.to_i*100
     mid = (max+min)/2
     mid_index = row_index.size/2
     row_index[mid_index] = mid
     row_index[-1] = min
     row_index
   }

   scale = 100/8.0

   arr
   .map{|e| (e/max.to_f)*scale }
   .map.with_index{|e, i|
     origin=i.pred.clamp(0, (max.to_f)*scale)
     prev_box_size=([nil]*((arr[origin]/max.to_f)*scale)).size
     box_arr=[BOX]*e
     if bar
      box_arr
     else
      slot=(0..scale).map{' '}
      start,stop=[prev_box_size, box_arr.size].minmax
      (start...stop).map{|i|
        slot[i]='|'
      }
      slot[box_arr.size]=[BOX]
      if [start,stop].uniq.size==1
        slot[box_arr.size]=[BOX_HORIZ_VERT]
      end
      slot.dup
     end
   }
   .to_balanced_array
   .map(&:reverse)
   .tap{|arr| arr.prepend(row_labels[arr]) }
   .to_table
 end

 def plot_map(data, **params)
  data=Marshal.load(Marshal.dump(data))
  min, max = data.minmax
  # detect below zero values and translate
  data.map!{|e| e+min.abs} if min < 0

  data.each_slice(70).map{|arr|
    plot(arr, **params){ [min, max] }
  }
 end
end
