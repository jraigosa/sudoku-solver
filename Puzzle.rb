require "Cell"

class Puzzle
	def initialize( args )
		if !args[:puzzle_grid].nil?
			#If we wanted to be through, we would do more validation here
			@dimension = args[:puzzle_grid].length
			@grid = Array.new(@dimension) { Array.new(@dimension) }
			args[:puzzle_grid].each_with_index { |row, i|
				row.each_with_index { |col, j|
					assignCell( i , j, row[j] )
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
		sudoku = Puzzle.new( 9 )
		for i in 0..8
			for j in 0..8
				sudoku.assignCell( i , i , lineArray[i][j] )
			end
		end
		return sudoku
	end
	
	def assignCells()
		for i in 0..(@dimension - 1)
			for j in 0..(@dimension - 1)
				puts "Enter sudoku.grid element #{i+1}, #{j+1}"
				STDOUT.flush
				val = gets.chomp.to_i
				cell = Cell.new( val, @dimension )
				@grid[i][j] = cell
			end
		end		
	end
	
	def assignCell( row, col, val )
		@grid[row][col] = Cell.new( val, @dimension )
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
		@dimension.times { |row|
			if @grid[row].any? { |cell| !cell.solved? }
				return false
			end
		}
		return true
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
		compareRowPossibles()
		compareColPossibles()
		compareBlockPossibles()
	end
	
	def compareRowPossibles()
		possiblesArray = Array.new(@dimension) { Array.new(@dimension) }
		@dimension.times { |i|
			@dimension.times { |j|
				possiblesArray[i][j] = @grid[i][j].possibles				
			}
			uniquePossibles = possiblesArray[i].uniq
			#puts "ROW #{ i+1 }"
			#puts "POSSIBLES ARRAY"
			#puts possiblesArray[i]
			#puts "UNIQUE ARRAY"
			#puts uniquePossibles
			matchArray = Array.new( uniquePossibles.size )
			if uniquePossibles.size >= 2
				for m in 0..(uniquePossibles.size - 1)
					#puts "M = #{ m }"
					for n in 0..(possiblesArray[i].size - 1)
						if uniquePossibles[m] == possiblesArray[i][n]
							if matchArray[m].nil?
								matchArray[m] = [n]
							else
								matchArray[m] << n
							end
						end
					end
					if ( ! matchArray[m].nil? ) && ( ! uniquePossibles[m].nil? ) && ( matchArray[m].size == uniquePossibles[m].size )
						#puts "ROW #{ i + 1 }"
						#puts "POSSIBLES #{ uniquePossibles[m] } size #{ uniquePossibles[m].size }"
						#puts "COL MATCHES #{ matchArray[m] } size #{ matchArray[m].size }"
						#puts "M = #{ m }"
						@dimension.times { |y|
							if ! matchArray[m].include?( y )
								for z in 0..(uniquePossibles[m].size - 1)
								#@uniquePossibles[m].size.times { |z|
									if ! @grid[ i ][ y ].solved?
										#puts "COMPARE ROW POSSIBLES"
										#puts "ROW #{ i + 1 } COL #{ y + 1 }"
										#puts "VALUE REMOVED #{ uniquePossibles[m][z] }"
										@grid[ i ][ y ].removeFromPossibles!( uniquePossibles[m][z] )
									end
								#}
								end
							end
						}
					end
				end
				
			end
		}
	end
	
	def compareColPossibles()
		possiblesArray = Array.new(@dimension) { Array.new(@dimension) }
		@dimension.times { |j|
			@dimension.times { |i|
				possiblesArray[i][j] = @grid[i][j].possibles				
			}
			uniquePossibles = possiblesArray[j].uniq
			#fix below
			matchArray = Array.new( uniquePossibles.size )
			if uniquePossibles.size >= 2
				for m in 0..(uniquePossibles.size - 1)
					#puts "M = #{ m }"
					for n in 0..(possiblesArray[j].size - 1)
						if uniquePossibles[m] == possiblesArray[j][n]
							if matchArray[m].nil?
								matchArray[m] = [n]
							else
								matchArray[m] << n
							end
						end
					end
					if ( ! matchArray[m].nil? ) && ( ! uniquePossibles[m].nil? ) && ( matchArray[m].size == uniquePossibles[m].size )
						#puts "COL #{ j + 1 }"
						#puts "POSSIBLES #{ uniquePossibles[m] } size #{ uniquePossibles[m].size }"
						#puts "ROW MATCHES #{ matchArray[m] } size #{ matchArray[m].size }"
						#puts "M = #{ m }"
						@dimension.times { |x|
							if ! matchArray[m].include?( x )
								for z in 0..(uniquePossibles[m].size - 1)
								#@uniquePossibles[m].size.times { |z|
									if ! @grid[ x ][ j ].solved?
										#puts "COMPARE COLUMN POSSIBLES"
										#puts "ROW #{ x + 1 } COL #{ j + 1 }"
										#puts "VALUE REMOVED #{ uniquePossibles[m][z] }"
										@grid[ x ][ j ].removeFromPossibles!( uniquePossibles[m][z] )
									end
								#}
								end
							end
						}
					end
				end
				
			end
		}
	end
	
	def compareBlockPossibles()
		possiblesArray = Array.new(@dimension) { Array.new(@dimension) }
		anchorArray = [ [0,0], [0,3], [0,6], [3,0], [3,3], [3,6], [6,0], [6,3], [6,6] ]
		@dimension.times { |k|
			blockPosition = 0
			for i in (anchorArray[k][0])..(anchorArray[k][0]+2)
				for j in (anchorArray[k][1])..(anchorArray[k][1]+2)
					possiblesArray[k][ blockPosition ] =  @grid[i][j].possibles
					#puts "block position #{ blockPosition }"
					#puts possiblesArray[k][ blockPosition ]
					blockPosition += 1
				end	
			end
			uniquePossibles = possiblesArray[k].uniq
			#puts "BLOCK #{ k+1 }"
			#puts "POSSIBLES ARRAY"
			#puts possiblesArray[k]
			#puts "UNIQUE ARRAY"
			#puts uniquePossibles
			matchArray = Array.new( uniquePossibles.size )
			if uniquePossibles.size >= 2
				for m in 0..(uniquePossibles.size - 1) #m counts thru the unique candidate combinations in the block
					for n in 0..( possiblesArray[k].size - 1 ) #n counts thru the candidate combinations for each cell in the block
						if uniquePossibles[m] == possiblesArray[k][n]
							if matchArray[m].nil?
								matchArray[m] = [n]
							else
								matchArray[m] << n
							end
						end
					end
					if ( ! matchArray[m].nil? ) && ( ! uniquePossibles[m].nil? ) && ( uniquePossibles[m].size > 1 ) && ( matchArray[m].size == uniquePossibles[m].size )
						puts "BLOCK #{ k + 1 }"
						puts "POSSIBLES #{ uniquePossibles[m] } size #{ uniquePossibles[m].size }"
						puts "CELL MATCHES #{ matchArray[m] } size #{ matchArray[m].size }"
						#puts "M = #{ m }"
						blockPosition = 0
						for i in (anchorArray[k][0])..(anchorArray[k][0]+2)
							for j in (anchorArray[k][1])..(anchorArray[k][1]+2)
								if ! matchArray[m].include?( blockPosition )
									for z in 0..(uniquePossibles[m].size - 1)
									#@uniquePossibles[m].size.times { |z|
										if ! @grid[ i ][ j ].solved?
											puts "COMPARE BLOCK POSSIBLES"
											puts "ROW #{ i + 1 } COL #{ j + 1 }"
											puts "VALUE REMOVED #{ uniquePossibles[m][z] }"
											@grid[ i ][ j ].removeFromPossibles!( uniquePossibles[m][z] )
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
	
	def checkRow!( row, col )
		cell_to_check = @grid[row][col]
		
		#Nothing to do if this cell is already solved
		if cell_to_check.solved?
			return
		end

		@grid[row].find_all{ |cell|
			cell.solved?
		}.each{ |cell| 
			cell_to_check.check!( cell.to_i )

			if cell_to_check.solved?
				return
			end
		}
	end
	
	def checkCol!( row, col )
		cell_to_check = @grid[row][col]

		#Nothing to do if this cell is already solved
		if cell_to_check.solved?
			return
		end

		@dimension.times { |i| 
			if i != row
				cell_to_check.check!( @grid[i][col].to_i )
			end

			if cell_to_check.solved?
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
						if @grid[i][j].possibleValue?( val + 1 )
							rowArray[i][val] = [j]
						end
					else
						if @grid[i][j].possibleValue?( val + 1 )
							rowArray[i][val] = rowArray[i][val] + [j]
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
						if @grid[i][j].possibleValue?( val + 1 )
							colArray[j][val] = [i]
						end
					else
						if @grid[i][j].possibleValue?( val + 1 )
							colArray[j][val] = colArray[j][val] + [i]
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
								if @grid[i][j].possibleValue?( val + 1 )
									coordinateArray[k][val] = [ i , j ]
								end
							#end
						else
							#if ! @grid[i][j].solved?
								if @grid[i][j].possibleValue?( val + 1 )
									coordinateArray[k][val] = coordinateArray[k][val] + [ i , j ]
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
							#puts "ASSIGNED CELL. ROW: #{ row + 1 } COL: #{ col + 1 }"
							#puts "VALUE: #{ val + 1 }"
							@grid[row][col].solve!(val + 1 )
						end
					elsif coordinateArray[k][val].size == 4
						if coordinateArray[k][val][0] == coordinateArray[k][val][2]
							#puts "Cells collinear along a row.  VAL: #{ val + 1 }"
							#puts "Cell 1:  ROW: #{ coordinateArray[k][val][0] + 1 } COL:  #{ coordinateArray[k][val][1] + 1 }"
							#puts "Cell 2:  ROW: #{ coordinateArray[k][val][2] + 1 } COL:  #{ coordinateArray[k][val][3] + 1 }"
							for y in 0..(@dimension-1)
								if ( (y != coordinateArray[k][val][1] ) && ( y != coordinateArray[k][val][3] ) )
									@grid[ coordinateArray[k][val][0] ][ y ].removeFromPossibles!( val + 1 )
								end
							end
						elsif coordinateArray[k][val][1] == coordinateArray[k][val][3]
							#puts "Cells collinear along a column. VAL: #{ val + 1 }"
							#puts "Cell 1:  ROW: #{ coordinateArray[k][val][0] + 1 } COL:  #{ coordinateArray[k][val][1] + 1 }"
							#puts "Cell 2:  ROW: #{ coordinateArray[k][val][2] + 1 } COL:  #{ coordinateArray[k][val][3] + 1 }"
							for x in 0..(@dimension-1)
								if ( (x != coordinateArray[k][val][0] ) && ( x != coordinateArray[k][val][2] ) )
									@grid[ x ][ coordinateArray[k][val][1] ].removeFromPossibles!( val + 1 )
								end
							end
						end

					elsif coordinateArray[k][val].size == 6
						if ( ( coordinateArray[k][val][0] == coordinateArray[k][val][2] ) && ( coordinateArray[k][val][0] == coordinateArray[k][val][4] ) )
							#puts "Cells collinear along a row. VAL: #{ val + 1 }"
							#puts "Cell 1:  ROW: #{ coordinateArray[k][val][0] + 1 } COL:  #{ coordinateArray[k][val][1] + 1 }"
							#puts "Cell 2:  ROW: #{ coordinateArray[k][val][2] + 1 } COL:  #{ coordinateArray[k][val][3] + 1 }"
							#puts "Cell 2:  ROW: #{ coordinateArray[k][val][4] + 1 } COL:  #{ coordinateArray[k][val][5] + 1 }"
							for y in 0..(@dimension-1)
								if ( (y != coordinateArray[k][val][1] ) && ( y != coordinateArray[k][val][3] ) && ( y != coordinateArray[k][val][5] ) )
									@grid[ coordinateArray[k][val][0] ][ y ].removeFromPossibles!( val + 1 )
								end
							end
						elsif ( ( coordinateArray[k][val][1] == coordinateArray[k][val][3] ) && ( coordinateArray[k][val][1] == coordinateArray[k][val][5] ) )
							#puts "Cells collinear along a column. VAL: #{ val + 1 }"
							#puts "Cell 1:  ROW: #{ coordinateArray[k][val][0] + 1 } COL:  #{ coordinateArray[k][val][1] + 1 }"
							#puts "Cell 2:  ROW: #{ coordinateArray[k][val][2] + 1 } COL:  #{ coordinateArray[k][val][3] + 1 }"
							#puts "Cell 2:  ROW: #{ coordinateArray[k][val][4] + 1 } COL:  #{ coordinateArray[k][val][5] + 1 }"
							for x in 0..(@dimension-1)
								if ( (x != coordinateArray[k][val][0] ) && ( x != coordinateArray[k][val][2] ) && ( x != coordinateArray[k][val][4] ) )
									@grid[ x ][ coordinateArray[k][val][1] ].removeFromPossibles!( val + 1 )
								end
							end
						end	
					end
				end	
			end
		end
	end
		
	def showPossibles( row, col )
		possibles = @grid[row][col].possibles
		puts possibles
	end
		
end