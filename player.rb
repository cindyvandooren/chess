require 'io/console'

class Player
  attr_accessor :color
  attr_reader :board, :name

  def initialize(name, board)
    @name, @board, @color = name, board, nil
  end

  def valid_origin?(origin)
    board.piece_at(origin).color == color
  end

  #To allow deselecting
  def valid_move?(origin, destination)
    raise InvalidMoveError if origin == destination
    board.piece_at(origin).valid_moves.include?(destination)
  end
end

class HumanPlayer < Player
  ARROWS = ["\e[A", "\e[B", "\e[C", "\e[D"]

  def get_move
    begin
      origin = get_point
      until valid_origin?(origin)
        origin = get_point
      end

      board.toggle_select
      destination = find_destination(origin)
    rescue InvalidMoveError
      board.toggle_select
      retry
    end
    board.toggle_select

    [origin, destination]
  end

  def find_destination(origin)
    destination = get_point

    until valid_move?(origin, destination)
      destination = get_point
    end

    destination
  end

  def get_movement
    STDIN.echo = false
    STDIN.raw!

    input = STDIN.getc.chr
    if input == "\e" then
      input << STDIN.read_nonblock(3) rescue nil
      input << STDIN.read_nonblock(2) rescue nil
    end
  ensure
    STDIN.echo = true
    STDIN.cooked!

    return input
  end

  def get_point
    action = nil

    until action == " "
      action = get_movement
      abort("Goodbye") if action == "q"
      raise SaveGameError if action == "s"
      next unless ARROWS.include?(action)
      board.map_deltas(action)
      system("clear")
      board.display
    end

    board.cursor
  end
end

class InvalidMoveError < StandardError
end

class SaveGameError < StandardError
end
