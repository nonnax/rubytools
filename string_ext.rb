class String
	def last(n)
		split(//).last(n).join
	end
	def scroll(slice: 10, repeat: 15)
	  (self*repeat).split(//).each_cons(slice).to_a.each{|e| yield e.join }
	  self
	end
	def take_cons(slice: 10, repeat: 15)
	  (self*repeat).split(//).each_cons(slice)
	end
end
