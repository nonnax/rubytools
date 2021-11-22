#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2021-11-04 20:44:33 +0800
require 'cuba'
require 'cuba/safe'
require 'rubytools/scooby'

Cuba.use Rack::Session::Cookie, secret: '__a_very_long_session_string__'
Cuba.plugin Cuba::Safe

Cuba.use Rack::Static, urls: ['/media', '/css']

class Cuba
  def render(use_layout: false, &block)
    body = Scooby.dooby(&block)
    res.write(
        use_layout ? _layout { body } : body
      )
  end

  def _layout(&block)
    # to be overriden
    Scooby.dooby do
      html do
        h1 { 'missing method: _layout()' }
        div(&block)
      end
    end
  end
end
