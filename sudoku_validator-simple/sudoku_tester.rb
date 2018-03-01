#!/usr/bin/env ruby

require "pp"

class SudokuBoardParser
  attr_reader :grid

  def initialize(board)
    contents = IO.read(board)
    sudoku_values = remove_non_digits(contents)
    @grid = convert_to_grid(sudoku_values)
  end

  private

  def remove_non_digits(contents)
    contents.gsub(/[^\d\.]/, '')
  end

  def convert_to_grid(contents)
    contents.chars.each_slice(9).to_a
  end
end

class RowChecker
  def initialize(grid)
    @grid = strip_dots(grid)
  end

  def valid?
    @grid.all? { |row| row.uniq.size == row.size }
  end

  private

  def strip_dots(grid)
    grid.map do |row|
      row.reject { |e| e == '.' }
    end
  end
end

class ColumnChecker
  def initialize(grid)
    @grid = RowChecker.new(grid.transpose)
  end

  def valid?
    @grid.valid?
  end
end

class SubGridChecker
  def initialize(grid)
    modified_grid = subgrids_to_rows(grid)
    @grid = RowChecker.new(modified_grid)
  end

  def valid?
    @grid.valid?
  end

  private

  def subgrids_to_rows(grid)
    grid.each_slice(3).each_with_object([]) do | rows, new_grid |
      new_grid.push(*row_of_subgrids(rows))
    end
  end

  def row_of_subgrids(rows)
    rows.flatten
      .each_slice(3)                        # in triples
      .group_by.with_index { |_, i| i % 3 } # group every third
      .map { |i, e| e.flatten }             # form a row from subgrid elements
  end
end

class SudokuTester
  attr_reader :sudoku_board

  def initialize(sudoku_board)
    @sudoku_board = sudoku_board
    @board = SudokuBoardParser.new(sudoku_board).grid
    @complete = !@board.flatten.any? { |e| e == '.' }
  end

  def is_valid?
    validation = [RowChecker, ColumnChecker, SubGridChecker]
    validation.all? { |v| v.new(@board).valid? }
  end

  def is_complete?
    @complete
  end

  def completeness
    if ((not is_complete?) && (not is_valid?))
      return ' and incomplete'
    end

    if (is_valid? && is_complete?)
      return ' and complete'
    end

    if (is_complete? && (not is_valid?))
      return ', but complete'
    end

    if ((not is_complete?) && is_valid?)
      return ', but incomplete'
    end
  end

  def result
    validity = self.is_valid? ? 'valid' : 'invalid'

    puts "The following board is #{validity}#{completeness}.\n\n"
    puts IO.read(sudoku_board)
  end
end

sudoku_board = SudokuTester.new(ARGV.first)
sudoku_board.result
