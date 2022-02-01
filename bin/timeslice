#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2022-02-01 16:08:51 +0800
#
# timeslice.rb <timestamp><n>

require 'rubytools/time_and_date_ext'
require 'csv'

max_ts, repeat = ARGV

exit unless [max_ts, repeat].all?

repeat &&= repeat.to_i

size = max_ts.to_ms / repeat

xtimes = []
repeat.times { |x| xtimes << x * size }
xtimes << max_ts.to_ms

sections = []
sections = (xtimes.size - 1)
           .times.map do |i|
  [xtimes[i], xtimes[i + 1]]
    .map(&:to_ts)
    .to_csv
end

sections.each { |s| puts s }
