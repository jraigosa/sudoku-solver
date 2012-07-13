class Cell
	def initialize( val, max_value )
		#todo: Check for invalid input values
		@val = val
		@possibles = @val.zero? ?
			(1..max_value).to_a :
			nil
	end
	
	def to_i
		return @val
	end

	def to_s
		return @val.zero? ?
			"·" :
			@val.to_s
	end
	
	def solved?
		return !@val.zero?
	end
	
	def solve!( val )
		#solvedCell = Cell.new( val )
		#return solvedCell
		@val = val
		@possibles = nil
	end
	
	def check!( solved_value )
		if solved_value > 0 && !@possibles.nil?
			#Delete the solved value from the list of possibles
			@possibles.delete( solved_value )

			#Solve the cell if there's only 1 possible value remaining
			if @possibles.size == 1
				#puts "SOLVED for #{ val }"
				#puts @possibles
				solve!( @possibles.first )
			end
		end
	end
	
	def possibleValue?(val)
		if !@possibles.nil?
			return @possibles.include?(val)
		else
			return val == @val #this is hacky.. need to think about it
		end
	end
	
	def removeFromPossibles!( val )
		if !@possibles.nil? 
			@possibles.delete( val )
			#puts "VAL REMOVED #{ val }"
		end
	end
	
	def possibles
		return @possibles
	end	
end