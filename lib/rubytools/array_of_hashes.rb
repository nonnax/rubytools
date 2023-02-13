#!/usr/bin/env ruby
# Id$ nonnax 2022-02-24 21:45:35 +0800

module ArrayOfHashes
  def query(h={})
    # selects hash elements where keys matches the regexp values.
    # multiple key criterias are AND'ed together
    # a query string is built from keys to be used by select method
    # the built query string is eval-led to generate the select method search criteria
    
    parse_keys_to_pattern_match = %{ 
      h => { 
        #{h.keys.map{|e| "#{e}:" }.join(', ') } 
      } 
    }

    search_keys = 
      h
      .keys
      .inject([]){|a, k|
        a << %{ d[:#{k}].to_s.match(#{k}) }.strip
      }
      .join(' && ')
    
    parsed_query = [parse_keys_to_pattern_match, search_keys].join("\n")

    select{ |d| eval parsed_query }
  end


  def grep_hash(**criteria, &block)
    # grep_hash(..., (:all?|:any?): true)
    # grep_hash({...}){|join| join.all?}
    # (any?: default)
    # dbase = [
    #   {username: 'nald', location: 'here', age: 118},
    #   {username: 'nald', location: 'home',  age: 21},
    #   {username: 'nonnax', location: 'home',  age: 18}
    # ]
    # 
    # p dbase.grep_hash(username: '\bna', age: 18, all?: true)
    # # all?:|any?: only key presence significant. any value is valid
    # p dbase.grep_hash(username: '\bna', age: 18, all?: 'yes')
    # p dbase.grep_hash(username: '\bna', age: 18, all?: 1)
    # p dbase.grep_hash(username: '\bna', age: 18, all?: nil)
    # # using a block for joins
    # p dbase.grep_hash(username: '\bna', age: 18){|join| join.any?}
    # p dbase.grep_hash(username: '\bna', age: 18){|e| e.all?}
    # p dbase.grep_hash(username: '\bna', age: 18){ false } # -> []

    join=criteria.key?(:all?) && :all?
    join ||= :any?
    # all?:|any?: only key presence significant. any value is valid
    select do |hsh|
      crit=
        criteria
          .except(:any?, :all?)
          .filter_map{|k, v|
            # criterias are regexp(s) 
            re = Regexp.new(v.to_s, ?i)
            hsh[k].to_s.match?(re)
        }
      if block
        block[crit] 
      else
        crit.send(join)
      end
    end
    rescue => e
      puts [
        e, 
        "#{__method__}( #{criteria.inspect} )", 
        e.backtrace
      ]
  end
end

Array.include(ArrayOfHashes)
# 
if __FILE__==$0 then
  dbase = [
    {username: 'nald', location: 'here', age: 118}, 
    {username: 'nald', location: 'home',  age: 21},
    {username: 'nonnax', location: 'home',  age: 18}
  ]

  p 'dbase.query(username: /no/)'
  p dbase.query(username: /no/)
  p "dbase.grep_hash(username: '\bna', age: 18, all?: true)"
  p dbase.grep_hash(username: '\bna', age: 18, all?: true)
  # all?:|any?: only key presence significant. any value is valid
  p 'dbase.grep_hash(username: "\\bna", age: 18, all?: "yes")'
  p dbase.grep_hash(username: "\\bna", age: 18, all?: "yes")
  p 'dbase.grep_hash(username: "\\bna", age: 18, all?: 1)'
  p dbase.grep_hash(username: "\\bna", age: 18, all?: 1)
  p 'dbase.grep_hash(username: "\\bna", age: 18, all?: nil)'
  p dbase.grep_hash(username: "\\bna", age: 18, all?: nil)
  p 'dbase.grep_hash(username: "\\bna", age: 18){|join| join.any?}'
  p dbase.grep_hash(username: "\\bna", age: 18){|join| join.any?}
  p 'dbase.grep_hash(username: "\\bna", age: 18){|join| join.all?}'
  p dbase.grep_hash(username: "\\bna", age: 18){|join| join.all?}
  p 'dbase.grep_hash(username: "\\bna", age: 18){ false }'
  p dbase.grep_hash(username: "\\bna", age: 18){ false }
end
