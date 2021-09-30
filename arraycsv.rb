#!/usr/bin/env ruby
# Id$ nonnax 2021-09-10 17:39:07 +0800
# csv pseudo-array 
require 'csv'
require 'forwardable'

class ArrayCSV
  extend Forwardable
  attr_accessor :dataframe

  def_delegators :@dataframe, :[], :size, :first, :last, :empty?, :map, :each, :sort_by
  
  def initialize(fname, mode='a')
    @fname=fname
    clear if mode =~ /^w/
    load
  end  
  
  def <<(data)
      CSV.open(@fname, 'a' ){|row| row<<data }
      @dataframe << data.dup
      self
  end
  alias append <<

  def minmax
    #yield to get column target
    @dataframe.map{|e| yield(e) }.minmax
  end
  
  def assoc(key)
    #select regexp matched keys
    @dataframe.select{|r| r.first.match(key)}.map
  end

  def values_at(*idx)
    @dataframe.map{|r| r.values_at(*idx) }.map
  end

  def to_a
    @dataframe
  end

  private

  def clear
  	File.exists?(@fname) && File.open(@fname, 'w'){|f|f.print ""}
  end
  
  def load
    @dataframe=File.exists?(@fname) ? CSV.parse(File.read(@fname), converters: %i[numeric]) : []
  end
  alias load_data load

end

__END__

data=ArrayCSV.new('test.csv')
10.times do
  data<<[Time.now.to_s, rand(10..100), rand(90..100), rand(10..90), rand(10..100)]
end

p data.class
p data
p data.methods-Object.methods
p data.size
p 'data.values_at(-1, 1)'
p data.values_at(-1, 1)
p 'data.assoc(/24/)'
p data.assoc(/24/)
p data.dataframe.transpose
p data.minmax{|r| r[1] }
# p data.minmax # runtime error
