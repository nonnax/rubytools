# frozen_string_literal: true

require 'rubytools/array_table'
require 'rubytools/ansi_color'

class Array
  def to_hbars(delimeter: ' ')
    def to_max_width
      maxwidth = map(&:size).max
      map!  do |r|
        l = r.ljust(maxwidth).split(//)
        sign = r.split(//).last
        sign == '-' ? l.map(&:red) : l.map(&:cyan)
      end
    end
    to_max_width
    map(&:reverse)
      .transpose
      .to_table(delimeter: delimeter)
  end
end

if __FILE__ == $PROGRAM_NAME
  data = []

  data << 'RONALDEVAN'
  data << 'RON'
  data << 'RONALD-'
  data << 'NALD'
  puts data
  puts
  puts data.to_hbars # (30)
end
