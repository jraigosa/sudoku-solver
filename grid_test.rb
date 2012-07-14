#!/usr/bin/env ruby
#  sudoku.grid_test.rb
#  
#
#  Created by Juan Raigosa on 6/29/12.
#  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
#
#  To run
#  ruby -w grid_test.rb

require "Sudoku"

continue = 1
while ! continue.zero?

=begin
	puts "Enter dimension for sudoku"
	STDOUT.flush
	dimension = gets.chomp.to_i
	sudoku = Sudoku.new( dimension )

    puts "Do you want to assign the square values?"
	STDOUT.flush
	yes = gets.chomp.to_i
	if ! yes.zero?
		sudoku.assignSquares()
	end
=end
	
	STDOUT.puts "Enter filename"
	STDOUT.flush
	file = STDIN.gets.chomp
	
	f = File.open( file )
	lines = f.readlines
	lineArray = Array.new( 9 )
	for i in 0..8
		lineArray[i] = eval( lines[i] )
	end
	sudoku = Sudoku.new( :dimension => 9 )
	for i in 0..8
		for j in 0..8
			sudoku.assignSquare( i , j, lineArray[i][j] )
		end
	end
	
	STDOUT.puts "1 to display sudoku, 0 to continue"
	STDOUT.flush
	yes = STDIN.gets.chomp.to_i
	if ! yes.zero?
		STDOUT.puts "\n#{sudoku}\n"
	end

	solve = 1
	while ! solve.zero?
		if ! yes.zero?
			sudoku.solve_iteration!()
			STDOUT.puts "\n#{sudoku}\n"
		end

=begin
		candidates = 1
		while ! candidates.zero?
			puts "Enter row:"
			STDOUT.flush
			row = gets.chomp.to_i - 1
			puts "Enter col:"
			STDOUT.flush
			col = gets.chomp.to_i - 1
			sudoku.showCandidates( row, col )
			puts "0 to stop.  1 to continue."
			STDOUT.flush
			candidates = gets.chomp.to_i
		end
=end

		STDOUT.puts "1 to continue solving, 0 to stop"
		STDOUT.flush
		solve = STDIN.gets.chomp.to_i
	end
	
	STDOUT.puts "0 to stop, 1 to continue"
	STDOUT.flush
	continue = STDIN.gets.chomp.to_i
end
