#!/usr/bin/env ruby
# Id$ nonnax 2022-02-15 11:10:01 +0800
# require 'chronic'
require 'rubytools/time_and_date_ext'
require 'rubytools/numeric_ext'

def date(s)
  Chronic.parse(s)
end

class String
  def to_date
    Chronic.parse(self)
  end
end

ARGF.each_line(chomp: true) do |l|
  begin
    puts eval(l)
  rescue=>e
    puts res = l.is_date? ? eval("date '#{l}'") : e.backtrace.last
  end
end


