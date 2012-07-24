require 'set'

board = 
  [
    [0, 0, 7, 5, 0, 0, 6, 3, 8],
    [0, 0, 5, 0, 0, 0, 0, 0, 1],
    [0, 3, 0, 0, 4, 8, 2, 0, 0],
    [0, 0, 0, 0, 2, 9, 5, 0, 0],
    [2, 1, 0, 7, 0, 5, 0, 8, 4],
    [0, 0, 9, 8, 1, 0, 0, 0, 0],
    [0, 0, 4, 9, 6, 0, 0, 2, 0],
    [1, 0, 0, 0, 0, 0, 7, 0, 0],
    [7, 6, 3, 0, 0, 2, 8, 0, 0]
  ]

  def solve_board(board)
    blank = get_first_blank(board)
    if  blank == [-1, -1]
      [board]
    else
      indices = initialize_indices(board)
      possible_values = get_possible_values(blank[0], blank[1], indices)
      possible_values.inject([]) do |solutions, v|
        clone_board = deep_copy_board(board)
        clone_board[blank[0]][blank[1]] = v
        solutions + solve_board(clone_board)
      end
    end
  end

  def get_first_blank(board)
    row_length = board.size
    column_length = board[0].size
    0.upto(row_length-1).inject([-1, -1]) do |zero, row_index|
      if zero == [-1, -1]
        0.upto(column_length-1).each do |column_index|
          if board[row_index][column_index] == 0
            zero = [row_index, column_index]
          end
        end
      end
      zero
    end
  end


  def board_complete?(board)
    board.inject(true) do |flag, row|
      if row.include?(0)
        false
      else
        flag
      end
    end
  end


  def initialize_indices(board)
    row_indices = []
    column_indices = []
    group_indices =  {}
    board.each_with_index do |row, row_index|
      row.each_with_index do |column, column_index|
        row_indices[row_index]||=Set.new
        row_indices[row_index].add(column)
        column_indices[column_index]||=Set.new
        column_indices[column_index].add(column)
        group = get_sector(row_index, column_index)
        group_indices[group]||=Set.new
        group_indices[group].add(column)
      end
    end
    {
      :row_indices => row_indices,
      :column_indices => column_indices,
      :group_indices => group_indices
    }
  end

  def get_sector(row_index, column_index)
    row_group = row_index/3
    column_group = column_index/3
    [row_group, column_group]
  end

  def get_possible_values(row_index, column_index, indices)
    combined =  (indices[:row_indices][row_index] |
          indices[:column_indices][column_index] |
          indices[:group_indices][get_sector(row_index, column_index)])

    valid_values = 1.upto(9).to_set
    answer = (valid_values - combined)
    (valid_values - combined)


  end

  #immutability
  def deep_copy_hash(hash)
    hash_deep = hash.clone
    hash.each_key do |key|
      hash_deep[key]=hash[key].clone
    end
  end

  def deep_copy_board(board)
    clone_board = board.clone
    board.each_with_index do |row, index|
      clone_board[index]= row.clone
    end
    clone_board
  end

  def print_board(solutions)
    solutions.each do |board|
      board.each do |row|
        puts "#{row.join("\t")}\n"
      end
    end
  end

  print_board(solve_board(board))
