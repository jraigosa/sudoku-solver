#
#  Array.rb
#  
#
#  Created by Juan Raigosa on 7/14/12.
#  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
#

class Array

	def value_locations( val )
		match_array = Array.new( self.size )
		if ! self.nil?
			self.size.times { |x|
				if self[x] == val
					match_array << x
				end
			}
			match_array.compact!
			return match_array
		else
			return nil
		end
	end
end
