#!/usr/bin/env ruby
# Id$ nonnax 2023-03-10 11:05:20 +0800

require 'open3'
class Gnuplot
  def self.u(*cols, file:'', with: :lines)
    file=@file || file
    @using<<"'#{file}' using #{cols.join(':')} with #{with}"
  end

  def self.make_tempfile(data)
    tf=Tempfile.new
    Filer.write_csv tf.path, data
    tf.path
  end

  def self.plot(f=nil, data:nil, xdata: nil, x2data: nil, terminal: :dumb, timefmt: "%Y-%m-%dT%H:%M", height:nil, width:nil, ylabel: '', xlabel: '', title: '', &block)
    @using = []
    @file = f
    @file = make_tempfile(data) if data

    xdata_time_section = nil

    if xdata==:time
      xdata_time_section =<<~___
      set xdata time
      set x2data #{x2data || :time}
      set timefmt '#{timefmt}'
      ___
    end

    instance_eval &block
    plot_cmd = "plot " + @using.join(", ")

    terminal_section = "set terminal dumb #{width} #{height}" if terminal==:dumb

    cmd =<<~___
      #{terminal_section}
      set datafile separator ','
      set key autotitle columnhead # use the first line as title
      set y2tics # enable second axis
      set x2tics # enable second axis
      set title '#{title}'
      set xlabel '#{xlabel}'
      set ylabel '#{ylabel}'

      #{xdata_time_section}
      #{plot_cmd}
    ___

    @output, _pid = Open3.capture2("gnuplot -p", stdin_data: cmd )
    puts
  end

  def self.puts
    rules = {
      hashes: {
        regexp: /\#/m,
        color: :red
      },
      stars: {
        regexp: /\*/m,
        color: :bright_yellow
      },
      dollar: {
        regexp: /\$/m,
        color: :bright_blue
      },
      upcase_words: {
        regexp: /[A-Z]{2,}/m,
        color: :bold
      },
      inside_round_brackets: {
        regexp: /\(.*?\)/m,
        color: :cyan
      },
    }

    Kernel.puts Rbcat.colorize(@output, rules: rules)
  end

end
