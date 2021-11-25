#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2021-11-04 20:44:33 +0800
require 'cuba'
require 'cuba/safe'
require 'tagz'
include Tagz.globally

Cuba.use Rack::Session::Cookie, secret: '__a_very_long_session_string__'
Cuba.plugin Cuba::Safe

Cuba.use Rack::Static, urls: ['/media', '/css']

class Cuba
  def render(layout: false, &block)
    res.write(
        layout ? _layout { tagz(&block) } : tagz(&block)
      )
  end

  def _layout(&block)
    # to be overriden
    tagz do
      html_ do
        h1_ { 'missing method: _layout(&block)' }
        div_(&block)
      end
    end
  end
end
