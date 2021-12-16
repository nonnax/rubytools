#!/usr/bin/env ruby
# frozen_string_literal: true

# simple tempfile cache
module Cache
  module_function

  @ttl = 60 * 30

  def ttl=(val)
    @ttl = val
  end

  def ttl
    @ttl
  end

  def cache
    @cache ||= {}
  end

  def tmp(key)
    "/tmp/#{key}"
  end

  def valid?(key)
    cached_file = tmp(key)
    File.exist?(cached_file) && (Time.now - File.open(cached_file).mtime <= @ttl)
  end

  def get(key)
    return nil unless valid?(key)

    File.read(tmp(key))
  end
  alias [] get

  def set(key, content)
    cache[key] = tmp(key)
    File.open(tmp(key), 'w').puts(content)
    content
  end
  alias []= set

  def cached(key = nil, **h)
    self.ttl = h[:ttl] if h[:ttl]
    if result = get(key)
      result
    else
      result = yield
      set(key, result)
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  loop do
    res = Cache.cached('testkey', ttl: 10) do
      IO.popen('coingecko').read
    end
    puts Time.now
    puts res
    sleep 1
  end
end
