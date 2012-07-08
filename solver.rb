#!/usr/bin/env ruby
#  solver.rb
#  
#  Created by Juan Raigosa on 6/29/12.
#  Copyright (c) 2012. All rights reserved.
#
#  To run
#  ruby -w solver.rb <filename>

require 'puzzle'

unless ARGV.length == 1
	puts "Please provide a filename for a sodoku puzzle."
	exit
end

puzzle_file = ARGV[0]

file = File.open( puzzle_file )
lines = file.readlines
lineArray = Array.new( 9 )
9.times{ |i| 
	lineArray[i] = eval( lines[i] )
}
sudoku = Puzzle.new( :puzzle_grid => lineArray )

STDOUT.print "Original\n"
STDOUT.print "#{sudoku}\n"

sudoku.solve!()

STDOUT.print "Solved\n"
STDOUT.print "#{sudoku}\n"