#!/usr/bin/env ruby
# Id$ nonnax 2022-09-09 23:19:26
# Monkey patch of Marshal and JSON
# Syntax sugar for:
# Mod.read(f)
# Mod.write(f, object)
#
require 'json'

module JSON
  def self.read(f, symbolize_names: true)
    parse File.read(f), symbolize_names:
  end
  def self.write(f, obj)
    File.write(f, JSON.pretty_generate(obj))
  end
end

module Marshal
  def self.read(f)
    Marshal.load File.read(f)
  end
  def self.write(f, obj)
    File.write(f, Marshal.dump(obj))
  end
end
