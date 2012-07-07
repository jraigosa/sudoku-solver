#!/usr/bin/env ruby
#  sudoku.grid_test.rb
#  
#
#  Created by Juan Raigosa on 6/29/12.
#  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
#
#  To run
#  ruby -w grid_test.rb

require "Puzzle"

continue = 1
while ! continue.zero?

=begin
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
