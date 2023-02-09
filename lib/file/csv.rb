#!/usr/bin/env ruby
# Id$ nonnax 2022-11-17 10:00:17
require_relative 'serializer'
require 'csv'
require 'date'

CSV::Converters[:timex] = lambda{|s|
  begin
    DateTime.parse(s).to_time
  rescue ArgumentError
    s
  end
}

class CSVFile < Serializer
  def read(**opts)
    v=CSV.read(@path, **opts.merge(header_converters: :symbol, converters: %i[all date timex]))
    if opts[:headers]
      v.map(&:to_h)
    else
      v
    end
  end
  def write(obj)
    File.write @path, to_csv(obj)
  end
  def to_csv(a)
    Array(a).map(&:to_csv).join
  end
end

