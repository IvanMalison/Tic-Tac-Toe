# Tic Tac Toe Game


class IllegalMoveError < Exception
end


class Game

  @@winning_index_sets = [[0, 3, 6],  # verticals
                          [1, 4, 7],
                          [2, 5, 8],
                          [0, 1, 2],  # horizontals
                          [3, 4, 5],
                          [6, 7, 8],
                          [0, 4, 8],  # diagonals
                          [2, 4, 6]]
  
  def initialize(board=nil, xs_move=true)
    @board = board || 9.times.map {nil}
    @xs_move = xs_move
  end

  def clone
    return Game.new(Array.new(@board), @xs_move)
  end

  def check_for_win
    @@winning_index_sets.each do |index_set|
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

  def xs_move?
    return @xs_move
  end

  def make_move(cell_index)
    raise IllegalMoveError unless move_legal?(cell_index)
    @board[cell_index] = xs_move? ? "X" : "O"
    @xs_move = !@xs_move
    return self
  end

  def legal_move_remains?
    @board.include? nil
  end

  def to_s
    return @board.map {|item| item.nil? ? "n" : item}.join()
  end
end


class PositionAnalysis
  attr_reader :game, :winner, :winning_move
  def initialize(game, winner, move)
    @game = game
    @winner = winner
    @winning_move = move
  end
end


class AI

  def initialize(game=nil)
    @position_to_analysis_map = {}
    perform_analysis_for_game(game || Game.new)
  end

  def perform_analysis_for_game(game)
    current_analysis = @position_to_analysis_map[game.to_s]
    return current_analysis unless current_analysis.nil?
    winner = game.check_for_win
    return PositionAnalysis.new(game, winner, nil) unless winner.nil?
    return PositionAnalysis.new(game, nil, nil) unless game.legal_move_remains?
    child_analyses = (0..8).select {|index| game.move_legal?(index)}.map {|index|
      [index, perform_analysis_for_game(game.clone.make_move(index))]
    }
    current_player = game.xs_move? ? "X" : "O"
    index_analysis_pair = child_analyses.find {|i, analysis| analysis.winner == current_player}
    if index_analysis_pair.nil?
      index_analysis_pair = child_analyses.find {|i, analysis| analysis.winner.nil?}
    end
    if index_analysis_pair.nil?
      index_analysis_pair = child_analyses[0]
    end
    index, analysis = index_analysis_pair
    analysis = PositionAnalysis.new(game, analysis.winner, index)
    @position_to_analysis_map[game.to_s] = analysis
    return analysis
  end

  def make_move_for_game(game)
    return @position_to_analysis_map[game.to_s].winning_move
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

  def play
    # if `@game.legal_move_remains?` then continue displaying board
    # and prompting user
    ai = AI.new
    while @game.legal_move_remains?
      puts board_string
      puts (@game.xs_move? ? "X" : "O") + "'s Move"
      unless @game.xs_move?
        begin
          @game.make_move(print_message_and_get_index("Enter position number:") - 1) #minus 1 for index
        rescue IllegalMoveError
          puts "That move was not valid"
        end
      else
        @game.make_move(ai.make_move_for_game(@game))
      end
      game_victor = @game.check_for_win
      if !game_victor.nil?
        puts board_string
        puts "#{game_victor} WINS THE GAME!"
        return
      end
    end
    puts "The game is tied!"
  end
  
end

UserInterface.new.play
