#!/usr/bin/env ruby
#  sudoku.grid_test.rb
#  
#
#  Created by Juan Raigosa on 6/29/12.
#  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
#
#  To run
#  ruby -w grid_test.rb


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


class Puzzle
	def initialize( dimension )
		@grid = Array.new(dimension) { Array.new(dimension) }
		@dimension = dimension
		rowArray = Array.new(dimension) { Array.new(dimension) }
		colArray = Array.new(dimension) { Array.new(dimension) }
		blockArray = Array.new(dimension) { Array.new(dimension) }
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
				cell = Cell.new( val )
				@grid[i][j] = cell
			end
		end		
	end
	
	def assignCell( row, col, val )
		cell = Cell.new( val )
		@grid[row][col] = cell
	end
	
	
	def display()
		x, y  = 1, 2
		for i in 0..(@dimension-1)
			tempArray = Array.new( @dimension )
			for j in 0..(@dimension-1)
				 tempArray[j] = @grid[i][j].to_i
			end
			puts tempArray.join(' ')
		end
	end
	
	def solve!()
		for i in 0..(@dimension - 1)
			for j in 0..(@dimension - 1)
				if ! @grid[i][j].solved?
					checkRow!(i,j)
					checkCol!(i,j)
					checkBlock!(i,j)
				end
			end
		end
		checkBlockComplete()
		checkRowComplete()
		checkColComplete()
	end
	
	def checkRow!( row, col )
		for j in 0..(@dimension-1)
			if j != col
				@grid[row][col].check!( @grid[row][j].to_i )
			end
		end
	end
	
	def checkCol!( row, col )
		for i in 0..(@dimension-1)
			if i != row
				@grid[row][col].check!( @grid[i][col].to_i )
			end
		end
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
						if @grid[i][j].possiblesCheck?( val + 1 )
							tempArray = [j]
							rowArray[i][val] = tempArray
						end
					else
						if @grid[i][j].possiblesCheck?( val + 1 )
							tempArray = [j]
							rowArray[i][val] = rowArray[i][val] + tempArray
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
						if @grid[i][j].possiblesCheck?( val + 1 )
							tempArray = [i]
							colArray[j][val] = tempArray
						end
					else
						if @grid[i][j].possiblesCheck?( val + 1 )
							tempArray = [i]
							colArray[j][val] = colArray[j][val] + tempArray
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
							if @grid[i][j].possiblesCheck?( val + 1 )
								tempArray = [ i , j ]
								coordinateArray[k][val] = tempArray
							end
						else
							if @grid[i][j].possiblesCheck?( val + 1 )
								tempArray = [ i , j ]
								coordinateArray[k][val] = coordinateArray[k][val] + tempArray
							end
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
							#puts "ASSIGNED CELL. ROW: #{ coordinateArray[k][val][0] + 1 } COL: #{ col = coordinateArray[k][val][1] + 1 }"
							#puts "VALUE: #{ val + 1 }"
							@grid[row][col].solve!(val + 1 )
						end
					elsif coordinateArray[k][val].size == 4
						if coordinateArray[k][val][0] == coordinateArray[k][val][2]
							puts "Cells collinear along a row.  VAL: #{ val + 1 }"
							puts "Cell 1:  ROW: #{ coordinateArray[k][val][0] + 1 } COL:  #{ coordinateArray[k][val][1] + 1 }"
							puts "Cell 2:  ROW: #{ coordinateArray[k][val][2] + 1 } COL:  #{ coordinateArray[k][val][3] + 1 }"
						elsif coordinateArray[k][val][1] == coordinateArray[k][val][3]
							puts "Cells collinear along a column. VAL: #{ val + 1 }"
							puts "Cell 1:  ROW: #{ coordinateArray[k][val][0] + 1 } COL:  #{ coordinateArray[k][val][1] + 1 }"
							puts "Cell 2:  ROW: #{ coordinateArray[k][val][2] + 1 } COL:  #{ coordinateArray[k][val][3] + 1 }"
						end
					elsif coordinateArray[k][val].size == 6
						if ( ( coordinateArray[k][val][0] == coordinateArray[k][val][2] ) && ( coordinateArray[k][val][0] == coordinateArray[k][val][4] ) )
							puts "Cells collinear along a row. VAL: #{ val + 1 }"
							puts "Cell 1:  ROW: #{ coordinateArray[k][val][0] + 1 } COL:  #{ coordinateArray[k][val][1] + 1 }"
							puts "Cell 2:  ROW: #{ coordinateArray[k][val][2] + 1 } COL:  #{ coordinateArray[k][val][3] + 1 }"
							puts "Cell 2:  ROW: #{ coordinateArray[k][val][4] + 1 } COL:  #{ coordinateArray[k][val][5] + 1 }"
						elsif ( ( coordinateArray[k][val][1] == coordinateArray[k][val][3] ) && ( coordinateArray[k][val][0] == coordinateArray[k][val][5] ) )
							puts "Cells collinear along a column. VAL: #{ val + 1 }"
							puts "Cell 1:  ROW: #{ coordinateArray[k][val][0] + 1 } COL:  #{ coordinateArray[k][val][1] + 1 }"
							puts "Cell 2:  ROW: #{ coordinateArray[k][val][2] + 1 } COL:  #{ coordinateArray[k][val][3] + 1 }"
							puts "Cell 2:  ROW: #{ coordinateArray[k][val][4] + 1 } COL:  #{ coordinateArray[k][val][5] + 1 }"
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


continue = 1
while ! continue.zero?

=begin rdoc
	puts "Enter dimension for puzzle"
	STDOUT.flush
	dimension = gets.chomp.to_i
	sudoku = Puzzle.new( dimension )

    puts "Do you want to assign the cell values?"
	STDOUT.flush
	yes = gets.chomp.to_i
	if ! yes.zero?
		sudoku.assignCells()
	end
=end
	
	puts "Enter filename"
	STDOUT.flush
	file = gets.chomp
	
	f = File.open( file )
	lines = f.readlines
	lineArray = Array.new( 9 )
	for i in 0..8
		lineArray[i] = eval( lines[i] )
	end
	sudoku = Puzzle.new( 9 )
	for i in 0..8
		for j in 0..8
			sudoku.assignCell( i , j, lineArray[i][j] )
		end
	end
	
	puts "1 to display puzzle, 0 to continue"
	STDOUT.flush
	yes = gets.chomp.to_i
	if ! yes.zero?
		puts
		sudoku.display()
		puts
	end

	solve = 1
	while ! solve.zero?
		if ! yes.zero?
			sudoku.solve!()
			sudoku.display()
		end

=begin rdoc
		possibles = 1
		while ! possibles.zero?
			puts "Enter row:"
			STDOUT.flush
			row = gets.chomp.to_i - 1
			puts "Enter col:"
			STDOUT.flush
			col = gets.chomp.to_i - 1
			sudoku.showPossibles( row, col )
			puts "0 to stop.  1 to continue."
			STDOUT.flush
			possibles = gets.chomp.to_i
		end
=end

		puts "1 to continue solving, 0 to stop"
		STDOUT.flush
		solve = gets.chomp.to_i
	end
	
	puts "0 to stop, 1 to continue"
	STDOUT.flush
	continue = gets.chomp.to_i
end
