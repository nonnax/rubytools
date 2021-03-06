#!/usr/bin/env ruby
# Id$ nonnax 2022-05-26 09:21:43 +0800
require 'erb'
require 'delegate'

class Table < SimpleDelegator
  def template    
    s=<<~___
      <% Array(self).each do |e| %>
        <%= e.map{|f| f.to_s.send(justify, padding)}.join(delimiter) %>
      <% end %>
    ___
  end

  def padding()=@padding||=3
  def delimiter=(d) @delimiter=d  end
  def delimiter(); @delimiter ||=' ' end
  def set_padding=(n); @padding=n end
  def auto_padding
    @padding=self.to_a.flatten.map{|e| e.to_s.size }.max
  end

  def justify
    @ljust ? :ljust : :rjust
  end

  def to_s(ljust:true)
    @ljust=ljust
    auto_padding
    ERB.new(template, trim_mode: '<>').result(binding)
  end
  alias to_table to_s
  
end
