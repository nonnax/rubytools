#!/usr/bin/env ruby
# Id$ nonnax 2022-03-22 17:36:02 +0800
require 'erb'

module RenderERB
  def render(binding_obj)
    ERB.new(self).result(binding_obj)
  end
  alias result render
end

module KernelExt
  def _render(f, **param)
    context_binding=param.fetch(:context, binding)
    ERB.new(f).result(context_binding)
  end

  def erb template, **param
    @param = param
    template_layout = param[:layout]

    f = File.read([template, 'erb'].join('.'))
    f_layout = File.read([template_layout, 'erb'].join('.')) if template_layout
    
    res= _render f, **param
    res= _render(f_layout){res} if template_layout
    res
  end
end

Kernel.include(KernelExt)
String.include(RenderERB)
