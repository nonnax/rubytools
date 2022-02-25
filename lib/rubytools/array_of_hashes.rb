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
end

Array.include(ArrayOfHashes)

# 
if __FILE__==$0 then
  dbase = [
    {username: 'nald', location: 'here', age: 11}, 
    {username: 'nald', location: 'home',  age: 21},
    {username: 'nonnax', location: 'home',  age: 18}
  ]

  p 'dbase.query(username: /no/)'
  p dbase.query(username: /no/)
end
