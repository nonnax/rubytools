#!/usr/bin/env ruby
# Id$ nonnax 2022-11-28 15:39:45
require 'file/file_ext'
require 'stringio'

module EnableCache
  def __file__
    __FILE__
  end
  
  def cache_path_using(*args)
    descrimitor = args.join('_').to_base64
    ['.', File.basename(__file__, '.*'), '-', descrimitor, '.cache'].join
  end

  def cache(timeout:30, on: self, path: nil, &block)
    string_io = StringIO.new
    m = eval('__method__', on.instance_eval{binding})
    path ||= ['.', File.basename( __FILE__, '.*'), '_', m, '.cache'].join
    dirname = File.dirname(path)
    Dir.mkdir(dirname)  unless Dir.exist?(dirname)

    output=
    if File.age(path) > timeout
      block.call(string_io)
      string_io
      .string
      .tap{|s| s && File.write(path, s.to_s) }
    else
      File.read(path)
    end
    puts output
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
