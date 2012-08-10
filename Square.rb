class Square
	def initialize( val, max_value )
		#todo: Check for invalid input values
		@val = val
		@candidates = @val.zero? ?
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
		#solvedSquare = Square.new( val )
		#return solvedSquare
		@val = val
		@candidates = nil
	end
	
	def check!( solved_value )
		if solved_value > 0 && !@candidates.nil?
			#Delete the solved value from the list of candidates
			@candidates.delete( solved_value )

			#Solve the square if there's only 1 candidate value remaining
			if @candidates.size == 1
				#puts "SOLVED for #{ val }"
				#puts @candidates
				solve!( @candidates.first )
			end
		end
	end
	
	def candidateValue?(val)
		if !@candidates.nil?
			return @candidates.include?(val)
		else
			return val == @val #this is hacky.. need to think about it
		end
	end
	
	def removeFromCandidates!( val )
		if !@candidates.nil? 
			@candidates.delete( val )
			#puts "VAL REMOVED #{ val }"
		end
	end
	
	def candidates
		return @candidates
	end	
end