#!/usr/bin/env ruby

require "pp"

class SudokuBoard
  attr_reader :board

  def initialize(grid)
    @board = []
    File.readlines(grid).each do |line|
      row = convert_line_to_row(line)
      @board << row unless row.nil?
    end
    pp @board
  end

  def missing_data?
    !(self.board.flatten.index(0)).nil?
  end

  def [](row, col)
    @board[row - 1][col - 1]
  end

  def []= (row, col, value)
    @board[row - 1][col - 1] = value
  end

  def row(row)
    @board[row - 1]
  end

  def col(col)
    column = []
    @board.each { |row| column << row[col - 1] }
    column
  end

  def sub_grid(number)
    # SubGrids are numbered 1-9 like this:
    #   1,2,3
    #   4,5,6
    #   7,8,9
    row, col = sub_grid_start(number)
    s_grid = []

    3.times do
      s_grid += sub_grid_row(row, col)
      row += 1
    end

    s_grid
  end

  private

  def convert_line_to_row(line)
    line.chomp!.delete!('-+| ')
    return nil if line.empty?
    line.tr!('.', '0')
    row = []
    line.each_char.map { |c| row << c.to_i }
    row
  end

  def sub_grid_row(row, col)
    [self[row, col], self[row, col + 1],self[row, col + 2]]
  end

  def sub_grid_start(sub_grid)
    row = ((sub_grid - 1) / 3) * 3 + 1
    col = ((sub_grid - 1) % 3) * 3 + 1
    [row, col]
  end
end

class SudokuTester
  attr_reader :board, :errors

  def initialize(grid)
    @grid = grid
    @board = SudokuBoard.new(@grid)
    @errors = []
  end

  def validate
    viability = check_grid_viability
    validity = check_grid_validity
    [validity, viability]
  end

  private

  def check_grid_viability
    @board.missing_data? ?  'incomplete' : 'complete'
  end

  def check_grid_validity
    rows_valid = check_row_validity
    cols_valid = check_col_validity
    subgrids_valid = check_subgrid_validity
    (rows_valid && cols_valid && subgrids_valid) ? 'valid' : 'invalid'
  end

  def check_row_validity
    valid_element?(:row)
  end

  def check_col_validity
    valid_element?(:col)
  end

  def check_subgrid_validity
    valid_element?(:sub_grid)
  end

  def valid_element?(element)
    item_valid = true
    (1..9).each do |item|
      valid, error = valid?(@board.__send__(element, item))
      item_valid &&= valid
      report_errors(error, element, item)
    end
    item_valid
  end

  def valid?(data)
    puts "----------"
    pp data
    tmp = data.map { |e| e if e != 0 }.compact
    pp tmp
    valid = tmp.uniq.size == tmp.size
    error = []
    error = identify_errors(tmp) if !valid
    puts "Error: #{error}"
    [valid, error]
  end

  def identify_errors(data)
    tmp = data.clone
    error = []
    while tmp.size > 0 do
      item = tmp.shift
      error << item if tmp.include? item
    end
    error
  end

  def report_errors (ary,where,item)
    ary.each { |e| @errors << "#{e} is repeated in #{where} #{item}" }
  end
end


sudoku_board = SudokuTester.new(ARGV.first)
validity, viability = sudoku_board.validate
puts "This sudoku is #{validity} and #{viability}."
sudoku_board.errors.each { |err| puts err }
