require_relative 'player'
require_relative 'board'
require 'yaml'

class Game

  def self.from_file(file_name)
    YAML.load_file(file_name)
  end

  def initialize
    @board = Board.new
    @players = [HumanPlayer.new("A", @board), HumanPlayer.new("B", @board)]
    set_colors
  end

  def run
    board.display
    until game_over?
      begin
        take_turn
      rescue SaveGameError
        save_game
        quit? ? abort("Goodbye") : retry
      end
    end

    end_of_game_message
  end

  def save_game
    puts "What would you like to call the game?"
    File.open(gets.chomp, 'w') do |f|
      f.puts self.to_yaml
    end
  end

  def quit?
    puts "q to quit, anything else to continue"
    gets.chomp.downcase == "q"
  end

  def end_of_game_message
    puts "CHECKMATE"
    puts "Congrats #{players.last.name}"
  end

  def game_over?
    board.checkmate?(players.first.color)
  end

  def take_turn
    move = players.first.get_move
    #return if move == :save
    board.move_piece(move)
    board.display
    players.rotate!
  end

  def set_colors
    players.first.color = :white
    players.last.color = :black
  end

  private
    attr_reader :players, :board
end

if __FILE__ == $PROGRAM_NAME
  puts "Would you like to (l)oad or start a (n)ew game."
  answer = gets.chomp.downcase
  if answer == "l"
    puts "Please enter the file name:"
    file_name = gets.chomp
    game = Game.from_file(file_name)
  else
    game = Game.new
  end
  game.run
end

## TO DO- ##############################################
# -add board#deep_dup
# -add movement into check filter
