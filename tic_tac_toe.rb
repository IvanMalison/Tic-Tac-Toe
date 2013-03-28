class IllegalMoveError < Exception
end

class Game

  attr_reader :is_x_move
  
  def initialize
    @board = 9.times.map {nil}
    @winning_index_sets = [[0, 3, 6], #verticals
                           [1, 4, 7],
                           [2, 5, 8],
                           [0, 1, 2], #horizontals
                           [3, 4, 5],
                           [6, 7, 8],
                           [0, 4, 8], #diagonals
                           [2, 4, 6]]
    @is_x_move = true
  end

  def is_move_legal(cell_index)
    ((0..8).include? cell_index) && @board[cell_index].nil?
  end

  def get_value_at_index(index)
    @board[index]
  end

  def make_move(cell_index)
    if @is_x_move
      x_move(cell_index)
    else
      o_move(cell_index)
    end
    @is_x_move = !@is_x_move
  end
  
  def x_move(cell_index)
    if is_move_legal(cell_index)
      @board[cell_index] = "X"
    else
      raise IllegalMoveError 
    end
  end

  def o_move(cell_index)
    if is_move_legal(cell_index)
      @board[cell_index] = "O"
    else
      raise IllegalMoveError 
    end
  end

  def check_for_win
    @winning_index_sets.each do |index_set|
      board_values = index_set.map {|index| @board[index]}
      if board_values == ["X", "X", "X"]
        return "X"
      elsif board_values == ["O", "O", "O"]
        return "O"
      end
    end
    return nil
  end

  def legal_move_remains?
    @board.include? nil
  end
end

class UserInterface

  def initialize
    @game = Game.new
    @bar = "----------"
  end

  def print_message_and_get_index(message)
    puts message
    gets.chomp.to_i
  end

  def ivan_display_board
    [(0..2), (3..5), (6..8)].map {|row_indices|
        row_indices.map {|index| value_to_print_at_cell_index(index)}.join(" | ") + "\n"
    }.join(@bar + "\n")
  end

  def display_board
    puts "#{value_to_print_at_cell_index 0} | #{value_to_print_at_cell_index 1} | #{value_to_print_at_cell_index 2}"
    puts @bar
    puts "#{value_to_print_at_cell_index 3} | #{value_to_print_at_cell_index 4} | #{value_to_print_at_cell_index 5}"
    puts @bar
    puts "#{value_to_print_at_cell_index 6} | #{value_to_print_at_cell_index 7} | #{value_to_print_at_cell_index 8}"
  end

  def value_to_print_at_cell_index(index)
    value = @game.get_value_at_index(index)
    if value.nil?
      return (index + 1).to_s
    else # value is an "X" or an "O"
      return value
    end
  end
  
  def play
    while @game.legal_move_remains?
      display_board
      game_victor = @game.check_for_win
      unless game_victor.nil?
        puts "#{game_victor} won."
        return
      end
      if @game.is_x_move
        puts "X's turn"
      else
        puts "O's turn"
      end
      begin
        @game.make_move(print_message_and_get_index("Enter position number.") - 1)
      rescue IllegalMoveError
        puts "That move was not valid"
      end
    end
    puts "The game is tied!"
  end
  
end


UserInterface.new.play
