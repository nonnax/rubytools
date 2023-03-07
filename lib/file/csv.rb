#!/usr/bin/env ruby
# Id$ nonnax 2022-11-17 10:00:17
require_relative 'serializer'
require 'csv'
require 'date'
require 'math/math_ext'
using MathExt

CSV::Converters[:timex] = lambda{|s|
  begin
    DateTime.parse(s).to_time
  rescue ArgumentError
    s
  end
}

class CSVFile < Serializer
  def read(**opts)
    opts[:headers]=opts.fetch(:vectors){true}
    v=CSV.read(@path, **opts.except(:vectors).merge(header_converters: :symbol, converters: %i[all date timex]))

    case opts
    in vectors: true
      v
      .map(&:to_h)
      .hashes_to_vectors
    in headers: true
      v
      .map(&:to_h)
    else
      v
    end

  end

  def write(obj)
    File.write @path, to_csv(to_df(obj))
  end

  def to_csv(a)
    Array(a).map(&:to_csv).join
  end

  def to_df(data)
    return data if Array===data.last
    data.map{|e| [e]}
  end

end

