class Cell
	def initialize( val )
		@val = val
		if @val.zero?
			@possibles = 1, 2, 3, 4, 5, 6, 7, 8, 9
		else
			@possibles = nil
		end
	end
	
	def to_i
		return @val
	end

	def to_s
		return @val == 0 ? "·" : @val.to_s
	end
	
	def solved?
		if @val.zero?
			return false
		else
			return true
		end
	end
	
	def solve!( val )
		#solvedCell = Cell.new( val )
		#return solvedCell
		@val = val
		@possibles = nil
	end
	
	def check!( val )
		if ! val.zero?
			if ! @possibles.nil?
				if @possibles.size == 1 
					#puts "SOLVED for #{ val }"
					#puts @possibles
					solve!( @possibles[0] )
				end
				if @possibles
					if @possibles.include?( val )
						tempArray = [ val ]
						@possibles = @possibles - tempArray
						#puts "VALUE #{ val } removed from possibles"
					end
				end
			end
		end
	end
	
	def possiblesCheck?(val)
		if !@possibles.nil?
			if @possibles.include?(val)
				return true
			else
				return false
			end
		else
			if val = @val  #this is hacky.. need to think about it
				return true
			else
				return false
			end
		end
	end
	
	def possibles
		return @possibles
	end	
end