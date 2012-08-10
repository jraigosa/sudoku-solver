require "Square"
require "Array"

class Sudoku

	def initialize( args )
		if !args[:sudoku_grid].nil?
			#If we wanted to be through, we would do more validation here
			@dimension = args[:sudoku_grid].length
			@grid = Array.new(@dimension) { Array.new(@dimension) }
			@solvedSquares = 0
			args[:sudoku_grid].each_with_index { |row, i|
				row.each_with_index { |col, j|
					assignSquare( i , j, row[j] )
				}
			}
		else 
			if !args[:dimension].nil?
			@dimension = args[:dimension]
			else
				#Assume a dimension of 9 if neither a dimension nor grid is provided
				@dimension = 9
			end
			@grid = Array.new(@dimension) { Array.new(@dimension) }
		end
		rowArray = Array.new(@dimension) { Array.new(@dimension) }
		colArray = Array.new(@dimension) { Array.new(@dimension) }
		blockArray = Array.new(@dimension) { Array.new(@dimension) }
	end
	
	def readFile( filename )
		f = File.open( filename )
		lines = f.readlines
		for i in 0..8
			lineArray[i] = eval( lines[0] )
		end
		sudoku = Sudoku.new( 9 )
		for i in 0..8
			for j in 0..8
				sudoku.assignSquare( i , i , lineArray[i][j] )
			end
		end
		return sudoku
	end
	
	def assignSquares()
		for i in 0..(@dimension - 1)
			for j in 0..(@dimension - 1)
				puts "Enter sudoku.grid element #{i+1}, #{j+1}"
				STDOUT.flush
				val = gets.chomp.to_i
				square = Square.new( val, @dimension )
				@grid[i][j] = square
			end
		end		
	end
	
	def assignSquare( row, col, val )
		@grid[row][col] = Square.new( val, @dimension )
	end
	
	def to_s
		output = String.new();
		block_dimension = Math.sqrt( @dimension )
		@dimension.times { |i| 
			if i > 0 && i % block_dimension == 0
				output += ( "-" * ( @dimension + 4 ) * ( block_dimension - 1 ) ) + "\n"
			end

			@dimension.times { |j| 
				if j > 0 && j % block_dimension == 0
					output += " |  "
				end
				output += "#{@grid[i][j]} "
			}

			output += "\n"
		}
		return output
	end

	def solved?
		@solvedSquares = 0
		@dimension.times do |row|
			@grid[row].each do |square|
				if square.solved?
					@solvedSquares += 1
				end
			end
			#if @grid[row].any? { |square| !square.solved? }
			#	return false
			#end
		end
		puts "solved squares #{@solvedSquares}"
		if @solvedSquares == (@dimension * @dimension )
			return true
		else
			return false
		end
		#return true
	end

	def solve!
		while !solved? 
			solve_iteration!()
		end
	end

	def solve_iteration!()
		@dimension.times { |i| 
			@dimension.times { |j| 
				if ! @grid[i][j].solved?
					checkRow!(i,j)
					checkCol!(i,j)
					checkBlock!(i,j)
				end
			}
		}
		checkBlockComplete()
		checkRowComplete()
		checkColComplete()
		compareRowCandidates()
		compareColCandidates()
		compareBlockCandidates()
		if ! valid?
			puts "Sudoku is not a valid puzzle."
		end
		if ! solved?
			puts "Sudoku is not yet solved"
		else
			puts "Sudoku is solved"
		end
	end
	
	def valid?()
		return rowValid? && colValid?
	end
	
	def rowValid?()
		@dimension.times do |row|
			rowArray = Array.new
			@grid[row].find_all do |square|
				if square.solved?
					rowArray << square.to_i
				end
			end
			if rowArray != rowArray.uniq
				return false
			else
				return true
			end
			#puts rowArray.inspect
		end
	end
	
	def colValid?()
		gridTranspose = @grid.transpose
		#puts gridTranspose.inspect
		@dimension.times do |col|
			colArray = Array.new
			gridTranspose[col].find_all do |square|
				if square.solved?
					colArray << square.to_i
				end
			end
			if colArray != colArray.uniq
				return false
			else
				return true
			end
			#puts rowArray.inspect
		end
	end
	
	def checkRow!( row, col )
		square_to_check = @grid[row][col]
		
		#Nothing to do if this square is already solved
		if square_to_check.solved?
			return
		end

		@grid[row].find_all{ |square|
			square.solved?
		}.each{ |square| 
			square_to_check.check!( square.to_i )

			if square_to_check.solved?
				return
			end
		}
	end
	
	def checkCol!( row, col )
		square_to_check = @grid[row][col]

		#Nothing to do if this square is already solved
		if square_to_check.solved?
			return
		end

		@dimension.times { |i| 
			if i != row
				square_to_check.check!( @grid[i][col].to_i )
			end

			if square_to_check.solved?
				return
			end
		}
	end
	
	def checkBlock!(row, col)
		if ( ( row + 1 ) % 3 ).zero?
			rowOffset = 3 - 1
		else
			rowOffset = ( ( row + 1 ) % 3 ) - 1
		end
		if ( ( col + 1 ) % 3 ).zero?
			colOffset = 3 - 1
		else
			colOffset = ( ( col + 1 ) % 3 ) - 1
		end
		for i in (row - rowOffset)..(row - rowOffset + 2 )
			for j in (col - colOffset)..(col - colOffset + 2 )
				if i != row
					if j != col
						@grid[row][col].check!( @grid[i][j].to_i )
					end
				end
			end
		end
		
	end
	
	def checkRowComplete()
		rowArray = Array.new(@dimension) { Array.new(@dimension) }
		for i in 0..(@dimension - 1 )
			for val in 0..(@dimension - 1 )
				for j in 0..(@dimension - 1 )
					if rowArray[i][val].nil?
						if @grid[i][j].candidateValue?( val + 1 )
							rowArray[i][val] = [j]
						end
					else
						if @grid[i][j].candidateValue?( val + 1 )
							rowArray[i][val] << j
							#rowArray[i][val] = rowArray[i][val] + [j]
						end
					end
				end
				if ! rowArray[i][val].nil?
					if rowArray[i][val].size == 1
						col = rowArray[i][val][0]
						if ! @grid[ i ][ col ].solved?
							#puts "ROW COMPLETE CHECK:"
							#puts "ROW: #{ i + 1 } COL: { COL + 1 } VAL: #{ val + 1 }"
							@grid[ i ][ col ].solve!( val + 1 )
						end
					end
				end
			end
		end		
	end	
	
	def checkColComplete()
		colArray = Array.new(@dimension) { Array.new(@dimension) }
		for j in 0..(@dimension - 1 )
			for val in 0..(@dimension - 1 )
				for i in 0..(@dimension - 1 )
					if colArray[j][val].nil?
						if @grid[i][j].candidateValue?( val + 1 )
							colArray[j][val] = [i]
						end
					else
						if @grid[i][j].candidateValue?( val + 1 )
							colArray[j][val] << i
							#colArray[j][val] = colArray[j][val] + [i]
						end
					end
				end
				if ! colArray[j][val].nil?
					if colArray[j][val].size == 1
						row = colArray[j][val][0]
						if ! @grid[ row ][ j ].solved?
							#puts "COL COMPLETE CHECK:"
							#puts "ROW: #{ row + 1 } COL: { j + 1 } VAL: #{ val + 1 }"
							@grid[ row ][ j ].solve!( val + 1 )
						end
					end
				end
			end
		end		
	end
	
	def checkBlockComplete()
		coordinateArray = Array.new(@dimension) { Array.new(@dimension) }
		anchorArray = [ [0,0], [0,3], [0,6], [3,0], [3,3], [3,6], [6,0], [6,3], [6,6] ]
		for k in 0..(@dimension - 1 )
			#puts "ROW: #{ anchorArray[k][0] } COL: #{ anchorArray[k][1] }"
			for val in 0..(@dimension-1)
				for i in (anchorArray[k][0])..(anchorArray[k][0]+2)
					for j in (anchorArray[k][1])..(anchorArray[k][1]+2)
					
						if coordinateArray[k][val].nil?
							#if ! @grid[i][j].solved?
								if @grid[i][j].candidateValue?( val + 1 )
									coordinateArray[k][val] = [ i , j ]
								end
							#end
						else
							#if ! @grid[i][j].solved?
								if @grid[i][j].candidateValue?( val + 1 )
									coordinateArray[k][val] << i  << j
									#coordinateArray[k][val] = coordinateArray[k][val] + [ i , j ]
								end
							#end
						end	
					#puts "ROW: #{ i+1 } COL: #{ j+1 }"
					end
				end
				if ! coordinateArray[k][val].nil?
					if coordinateArray[k][val].size == 2
						row = coordinateArray[k][val][0]
						col = coordinateArray[k][val][1]
						if ! @grid[ row ][ col ].solved?
							#puts "BLOCK COMPLETE CHECK: BLOCK: #{ k + 1 }"
							#puts "ASSIGNED SQUARE. ROW: #{ row + 1 } COL: #{ col + 1 }"
							#puts "VALUE: #{ val + 1 }"
							@grid[row][col].solve!(val + 1 )
						end
					elsif coordinateArray[k][val].size == 4
						if coordinateArray[k][val][0] == coordinateArray[k][val][2]
							#puts "Squares collinear along a row.  VAL: #{ val + 1 }"
							#puts "Square 1:  ROW: #{ coordinateArray[k][val][0] + 1 } COL:  #{ coordinateArray[k][val][1] + 1 }"
							#puts "Square 2:  ROW: #{ coordinateArray[k][val][2] + 1 } COL:  #{ coordinateArray[k][val][3] + 1 }"
							for y in 0..(@dimension-1)
								if ( (y != coordinateArray[k][val][1] ) && ( y != coordinateArray[k][val][3] ) )
									@grid[ coordinateArray[k][val][0] ][ y ].removeFromCandidates!( val + 1 )
								end
							end
						elsif coordinateArray[k][val][1] == coordinateArray[k][val][3]
							#puts "Squares collinear along a column. VAL: #{ val + 1 }"
							#puts "Square 1:  ROW: #{ coordinateArray[k][val][0] + 1 } COL:  #{ coordinateArray[k][val][1] + 1 }"
							#puts "Square 2:  ROW: #{ coordinateArray[k][val][2] + 1 } COL:  #{ coordinateArray[k][val][3] + 1 }"
							for x in 0..(@dimension-1)
								if ( (x != coordinateArray[k][val][0] ) && ( x != coordinateArray[k][val][2] ) )
									@grid[ x ][ coordinateArray[k][val][1] ].removeFromCandidates!( val + 1 )
								end
							end
						end

					elsif coordinateArray[k][val].size == 6
						if ( ( coordinateArray[k][val][0] == coordinateArray[k][val][2] ) && ( coordinateArray[k][val][0] == coordinateArray[k][val][4] ) )
							#puts "Squares collinear along a row. VAL: #{ val + 1 }"
							#puts "Square 1:  ROW: #{ coordinateArray[k][val][0] + 1 } COL:  #{ coordinateArray[k][val][1] + 1 }"
							#puts "Square 2:  ROW: #{ coordinateArray[k][val][2] + 1 } COL:  #{ coordinateArray[k][val][3] + 1 }"
							#puts "Square 2:  ROW: #{ coordinateArray[k][val][4] + 1 } COL:  #{ coordinateArray[k][val][5] + 1 }"
							for y in 0..(@dimension-1)
								if ( (y != coordinateArray[k][val][1] ) && ( y != coordinateArray[k][val][3] ) && ( y != coordinateArray[k][val][5] ) )
									@grid[ coordinateArray[k][val][0] ][ y ].removeFromCandidates!( val + 1 )
								end
							end
						elsif ( ( coordinateArray[k][val][1] == coordinateArray[k][val][3] ) && ( coordinateArray[k][val][1] == coordinateArray[k][val][5] ) )
							#puts "Squares collinear along a column. VAL: #{ val + 1 }"
							#puts "Square 1:  ROW: #{ coordinateArray[k][val][0] + 1 } COL:  #{ coordinateArray[k][val][1] + 1 }"
							#puts "Square 2:  ROW: #{ coordinateArray[k][val][2] + 1 } COL:  #{ coordinateArray[k][val][3] + 1 }"
							#puts "Square 2:  ROW: #{ coordinateArray[k][val][4] + 1 } COL:  #{ coordinateArray[k][val][5] + 1 }"
							for x in 0..(@dimension-1)
								if ( (x != coordinateArray[k][val][0] ) && ( x != coordinateArray[k][val][2] ) && ( x != coordinateArray[k][val][4] ) )
									@grid[ x ][ coordinateArray[k][val][1] ].removeFromCandidates!( val + 1 )
								end
							end
						end	
					end
				end	
			end
		end
	end
	
	def compareRowCandidates()
		candidatesArray = Array.new(@dimension) { Array.new(@dimension) }
		@dimension.times { |i|
			@dimension.times { |j|
				candidatesArray[i][j] = @grid[i][j].candidates				
			}
			uniqueCandidates = candidatesArray[i].uniq
			uniqueCandidates.compact! #removes nil elements from array
			matchArray = Array.new()
			if uniqueCandidates.size >= 2
				for m in 0..(uniqueCandidates.size - 1)
					#puts "M = #{ m }"
					#puts "UNIQUE CANDIDATE #{ uniqueCandidates[m] }"
					#puts "candidates array #{ candidatesArray[i].join(',') }"
					#puts "candidates array #{ candidatesArray.join(',') }"
					matchArray[m] = candidatesArray[i].value_locations( uniqueCandidates[m] )
					#puts "match array #{ matchArray[m].join(',') }"
					#puts "match array size #{ matchArray[m].size }"
					if ( ! matchArray[m].nil? ) && ( ! uniqueCandidates[m].nil? ) && ( matchArray[m].size == uniqueCandidates[m].size )
						@dimension.times { |y|
							if ! matchArray[m].include?( y )
								uniqueCandidates[m].size.times { |z|
									if ! @grid[ i ][ y ].solved?
										#puts "COMPARE ROW CANDIDATES"
										#puts "ROW #{ i + 1 } COL #{ y + 1 }"
										#puts "VALUE REMOVED #{ uniqueCandidates[m][z] }"
										@grid[ i ][ y ].removeFromCandidates!( uniqueCandidates[m][z] )
									end
								}
							end
						}
					end
				end
				
			end
		}
	end
	
	def compareColCandidates()
		candidatesArray = Array.new(@dimension) { Array.new(@dimension) }
		@dimension.times { |j|
			@dimension.times { |i|
				candidatesArray[i][j] = @grid[i][j].candidates				
			}
			uniqueCandidates = candidatesArray[j].uniq
			uniqueCandidates.compact! #removes nil elements from array
			#fix below
			matchArray = Array.new()
			if uniqueCandidates.size >= 2
				for m in 0..(uniqueCandidates.size - 1)
					#puts "M = #{ m }"
					matchArray[m] = candidatesArray[j].value_locations( uniqueCandidates[m] )
					if ( ! matchArray[m].nil? ) && ( ! uniqueCandidates[m].nil? ) && ( matchArray[m].size == uniqueCandidates[m].size )
						#puts "COL #{ j + 1 }"
						#puts "CANDIDATES #{ uniqueCandidates[m] } size #{ uniqueCandidates[m].size }"
						#puts "ROW MATCHES #{ matchArray[m] } size #{ matchArray[m].size }"
						#puts "M = #{ m }"
						@dimension.times { |x|
							if ! matchArray[m].include?( x )
								uniqueCandidates[m].size.times { |z|
									if ! @grid[ x ][ j ].solved?
										#puts "COMPARE COLUMN CANDIDATES"
										#puts "ROW #{ x + 1 } COL #{ j + 1 }"
										#puts "VALUE REMOVED #{ uniqueCandidates[m][z] }"
										@grid[ x ][ j ].removeFromCandidates!( uniqueCandidates[m][z] )
									end
								}
							end
						}
					end
				end
				
			end
		}
	end
	
	def compareBlockCandidates()
		candidatesArray = Array.new(@dimension) { Array.new(@dimension) }
		anchorArray = [ [0,0], [0,3], [0,6], [3,0], [3,3], [3,6], [6,0], [6,3], [6,6] ]
		@dimension.times { |k|
			blockPosition = 0
			for i in (anchorArray[k][0])..(anchorArray[k][0]+2)
				for j in (anchorArray[k][1])..(anchorArray[k][1]+2)
					candidatesArray[k][ blockPosition ] =  @grid[i][j].candidates
					#puts "block position #{ blockPosition }"
					#puts candidatesArray[k][ blockPosition ]
					blockPosition += 1
				end	
			end
			uniqueCandidates = candidatesArray[k].uniq
			uniqueCandidates.compact! #removes nil elements from array
			#puts "BLOCK #{ k+1 }"
			#puts "CANDIDATES ARRAY"
			#puts candidatesArray[k]
			#puts "UNIQUE ARRAY"
			#puts uniqueCandidates
			matchArray = Array.new( uniqueCandidates.size )
			if uniqueCandidates.size >= 2
				for m in 0..(uniqueCandidates.size - 1) #m counts thru the unique candidate combinations in the block
					matchArray[m] = candidatesArray[k].value_locations( uniqueCandidates[m] )
					if ( ! matchArray[m].nil? ) && ( ! uniqueCandidates[m].nil? ) && ( uniqueCandidates[m].size > 1 ) && ( matchArray[m].size == uniqueCandidates[m].size )
						#puts "BLOCK #{ k + 1 }"
						#puts "CANDIDATES #{ uniqueCandidates[m] } size #{ uniqueCandidates[m].size }"
						#puts "SQUARE MATCHES #{ matchArray[m] } size #{ matchArray[m].size }"
						#puts "M = #{ m }"
						blockPosition = 0
						for i in (anchorArray[k][0])..(anchorArray[k][0]+2)
							for j in (anchorArray[k][1])..(anchorArray[k][1]+2)
								if ! matchArray[m].include?( blockPosition )
									for z in 0..(uniqueCandidates[m].size - 1)
									#@uniqueCandidates[m].size.times { |z|
										if ! @grid[ i ][ j ].solved?
											#puts "COMPARE BLOCK CANDIDATES"
											#puts "ROW #{ i + 1 } COL #{ j + 1 }"
											#puts "VALUE REMOVED #{ uniqueCandidates[m][z] }"
											@grid[ i ][ j ].removeFromCandidates!( uniqueCandidates[m][z] )
										end
									#}
									end
								end
								blockPosition += 1
							end	
						end
					end
				end
			end
		}
	end
	
	
	# Probably obsolete.  Takes a row and column that references a particular square/square and returns the candidates		
	def showCandidates( row, col )
		candidates = @grid[row][col].candidates
		puts candidates
	end
		
end