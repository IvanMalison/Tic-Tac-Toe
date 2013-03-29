# Tic Tac Toe Game


class IllegalMoveError < Exception
end


class Game

  # makes instance variable public by adding a function that accesses
  # the underlying value with the same name as the underlying value.
  # `attr_reader` and not `attr_accessor` because users of class never need to
  # modify `is_x_move?` variable
  def xs_move?
    return @xs_move
  end
    
  
  def initialize
    @board = 9.times.map {nil}
    @winning_index_sets = [[0, 3, 6],  # verticals
                           [1, 4, 7],
                           [2, 5, 8],
                           [0, 1, 2],  # horizontals
                           [3, 4, 5],
                           [6, 7, 8],
                           [0, 4, 8],  # diagonals
                           [2, 4, 6]]
    @xs_move = true
  end

  def check_for_win
    @winning_index_sets.each do |index_set|
      board_values = index_set.map {|index| @board[index]}
      return "X" if board_values == ["X", "X", "X"]
      return "O" if board_values == ["O", "O", "O"]
    end
    return nil
  end

  def get_value_at_index(index)
    @board[index]
  end

  def move_legal?(cell_index)
    ((0..8).include? cell_index) && @board[cell_index].nil?
  end

  def make_move(cell_index)
    raise IllegalMoveError unless move_legal?(cell_index)
    @board[cell_index] = xs_move? ? "X" : "O"
    @xs_move = !@xs_move
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

  def board_string
    [(0..2), (3..5), (6..8)].map {|row_indices|
        row_indices.map {|index| value_to_print_at_cell_index(index)}.join(" | ") + "\n"
    }.join(@bar + "\n")
  end

  def value_to_print_at_cell_index(index)
    value = @game.get_value_at_index(index)
    if value.nil?
      return (index + 1).to_s
    else # value is an "X" or an "O"
      return value
    end
  end

  # def display_board
  #   puts "#{value_to_print_at_cell_index 0} | #{value_to_print_at_cell_index 1} | #{value_to_print_at_cell_index 2}"
  #   puts @bar
  #   puts "#{value_to_print_at_cell_index 3} | #{value_to_print_at_cell_index 4} | #{value_to_print_at_cell_index 5}"
  #   puts @bar
  #   puts "#{value_to_print_at_cell_index 6} | #{value_to_print_at_cell_index 7} | #{value_to_print_at_cell_index 8}"
  # end

  def play
    # if `@game.legal_move_remains?` then continue displaying board and prompting user
    while @game.legal_move_remains?
      puts board_string
      puts (@game.xs_move? ? "X" : "O") + "'s Move"
      begin
        @game.make_move(print_message_and_get_index("Enter position number:") - 1) #minus 1 for index
      rescue IllegalMoveError
        puts "That move was not valid"
      end
      game_victor = @game.check_for_win
      if !game_victor.nil?
        puts "#{game_victor} WINS THE GAME!"
        return
      end
    end
    puts "The game is tied!"
  end
  
end

UserInterface.new.play
