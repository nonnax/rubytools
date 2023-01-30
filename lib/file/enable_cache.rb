#!/usr/bin/env ruby
# Id$ nonnax 2022-11-28 15:39:45
require 'file/file_ext'

module EnableCache
  def cache(timeout:30, on: obj,  path:'/tmp/coinalyze.csv', &block)
    m = eval('__method__', on.instance_eval{binding})
    path = ['.', File.basename( __FILE__, '.*'), '_', m, '.cache'].join
    dirname = File.dirname(path)
    Dir.mkdir(dirname)  unless Dir.exist?(dirname)

    if File.age(path) > timeout
      block
      .call
      .tap{|s| s && File.write(path, s.to_s) }
    else
      File.read(path)
    end
  end
end

class EnabledCache
  include EnableCache
end

# class T < EnabledCache
	# def hey
	  # cache on: self do
	    # 'hello'
	  # end
	# end
# end
