#!/usr/bin/env ruby
# Id$ nonnax 2021-11-04 20:44:33 +0800
require 'cuba'
require 'scooby'

Cuba.use Rack::Static, :urls => ["/media"]

class Cuba
  def render(&block)
    res.write Scooby.dooby &block
  end
end
