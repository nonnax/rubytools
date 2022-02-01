#!/usr/bin/env ruby
# Id$ nonnax 2021-09-10 17:39:07 +0800
# csv pseudo-array 
require 'csv'
require 'forwardable'
require 'rubytools/thread_ext'

class Array
  def to_csv
    str = ''
    CSV.generate(str) do |csv|
      csv << self
    end
    str
  end
end

class ArrayCSV
  extend Forwardable
  attr_writer :dataframe
  def_delegators :@dataframe, :[], :size, :first, :last, :empty?, :map, :each, :sort_by, :reverse, :sort
  
  def initialize(fname, mode='a+', autosave: true)
    @fname=fname
    @autosave=autosave
    clear if mode.match(/^w/)
    load
    self
  end
  
  def self.parse(fname)
     new(fname, 'r',  autosave: false).dataframe
  end
  
  def self.open(fname, mode='a+', autosave: false, &block)
    obj=new(fname, mode, autosave: autosave)
    obj.instance_eval{ block.call(obj)}
    obj.save
    obj.to_a
  end

  def dataframe
    yield(@dataframe) if block_given?
    save if @autosave
    @dataframe
  end
  
  def prepend(*a)
    @dataframe.prepend(*a)
    save if @autosave
    self
  end
  
  def <<(*a)
    @dataframe << a.dup.flatten
    save if @autosave
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

  def inspect
    @dataframe.inspect
  end

  def save
    # save dataframe
    return if @dataframe.compact.empty?
    Thread.new do
      File.write(@fname, @dataframe.map(&:to_csv).join)
    end.join
    self
  end

  def method_missing(m, *a, **h, &block)
    @dataframe.send m, *a, **h, &block
  end


  def clear
    File.exists?(@fname) && File.open(@fname, 'w'){|f|f.print ""}
  end
  
  def load
    Thread.new do
      @dataframe=File.exists?(@fname) ? CSV.parse(File.read(@fname), converters: %i[numeric date]) : []
    end.join
    self
  end
  alias load_data load

end

if __FILE__==$PROGRAM_NAME 
  data=ArrayCSV.new('test.csv')
  t=Thread.new do
    1000.times do
      data<<[Time.now.to_s, rand(10..100), rand(90..100), rand(10..90), rand(10..100)]
    end
  end

  p data.class
  p data
  p data.methods-Object.methods
  p data.size
  p 'data.values_at(-1, 1)'
  p data.values_at(-1, 1).size
  p 'data.assoc(/24/)'
  p data.assoc(/24/).size
  p data.dataframe.transpose
  p data.minmax{|r| r[1] }
  # p data.minmax # runtime error

  t.join
end
