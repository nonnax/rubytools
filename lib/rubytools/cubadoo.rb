#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2021-11-04 20:44:33 +0800
require 'cuba'
require 'cuba/safe'
require 'tagz'
require 'rack/session'
require 'rubytools/cache'
require 'digest'

include Tagz.globally

Cuba.use Rack::Static,
    urls: %w[/css /images /js /media],
    root: 'public'

Cuba.use Rack::Session::Cookie,
    secret: Digest::SHA256.hexdigest( '__a_very_Very_lo0Ong_sess1on_str1ng__')

Cuba.plugin Cuba::Safe

class Cuba
  def render(**h, &block)
    rendered = h[:layout] ? _layout { tagz(&block) } : tagz(&block)

    if f = h[:cache]
      ttl = (h[:ttl] ||= 300)
      p "fetching cache...#{ttl}"
      content=Cache.cached(f, ttl: ttl) { rendered }
      res.write content
    else
      res.write rendered
    end
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

  def un(text)
    Rack::Utils.unescape(text)
  end
end
