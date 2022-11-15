#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2022-07-23 20:52:23

module ArrayStore
  refine Array do
    # Array file store
    # Ensure unique entries using push()
    def save(fname)
      File.open(fname, 'w+') do |f|
        # returns false if already locked, 0 if not
        _ret = f.flock(File::LOCK_EX | File::LOCK_NB)

        uniq!

        f.write Marshal.dump(self)
      end
    rescue StandardError => e
      puts "Error saving #{fname}"
    end

    def load(f)
      replace Marshal.load(File.read(f))
    rescue StandardError
      puts "Error loading #{f}"
    end

    # hash array chainable utils
    def grep_hash(re, *keys, &block)
      # grep a list of keys
      select { |h| keys.any? { |k| h[k].to_s.match?(re) } }
      .tap { |a| a.map(&block) if block }
    end

    def match?(re, *keys, &block)
      # match any from a list of keys
      keys = first&.keys if keys.empty? #use `default` keys if none-given
      select { |h| keys.any? { |k| h[k].to_s.match?(re) } }
      .tap { |a| a.map(&block) if block }
    end

    def at(*keys, &block)
    # slices each hash element for the keys
    # iterates if block given
      map { |h|
        h.slice(*keys)
         .tap { |hs| block[hs] if block }
      }
    end
    alias :[] :at

    def select_all?(**h)
      # ex. h = { key2searchA => re_to_matchA, key2searchB => re_to_matchB }
      # `all` re per key must match == true
      select do |d|
        h.keys.all? do |k|
          d[k].to_s.match?(h[k])
        end
      end
    end

    def select_any?(**h)
      # ex. h = { key2searchA => re_to_matchA, key2searchB => re_to_matchB }
      # `any` re for any key must match == true
      select do |d|
        h.keys.any? do |k|
          d[k].to_s.match?(h[k])
        end
      end
    end
  end
end
