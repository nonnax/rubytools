#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2022-09-16 00:26:58
#
# Hash refinement to flatten hash
# require 'hash_ext'
# using HashExt
# if the value of a key is an array
# splat each value item into a new hash with key<index> key names
#

module HashExt
  refine Hash do
    def deep_flatten
      # produces a new flattened hash; renaming keys where appropriate
      # uses recursive descent to flatten deeply nested branches
      newh = {}

      each_with_object(newh) do |(k, v), h|
        case v
        when Array
          vf = v.flatten       # we only want flat arrays

          vf.each_with_index do |e, i|
            h[[k, i].join] = e # remap values with numbered keys
          end
        when Hash
          v.map do |(vk, vv)|
            h[[k, vk].join('_')] = vv # create joined key names, e.g. `outer_inner`
          end
        else
          h[k] = v
        end
      end
        .then do |h|
        # flatten nested values
        newh = h.deep_flatten if h.values.any? { |e| e.is_a?(Hash) || e.is_a?(Array) }
      end
      newh
    end
  end
end

# Id$ nonnax 2021-11-16 10:11:27 +0800
require 'uri'

module QueryStringHelper
  def to_query_string(repeat_keys: false)
    repeat_keys ? send(:_repeat_keys) : send(:_single_keys)
  end

  def _single_keys
    inject([]) do |a, (k, v)|
      case v
      when Hash
        v = v._single_keys
      when Array
        v = v.join(',')
      end
      a << [k, v].join('=')
    end.join('&')
  end
  private :_single_keys

  def _repeat_keys
    URI.encode_www_form(self)
  end
  private :_repeat_keys
end

module PrintFormatter
  def format(fmt_str)
    Kernel.format(fmt_str, self)
  end
end

Hash.include(QueryStringHelper)
Hash.include(PrintFormatter)
