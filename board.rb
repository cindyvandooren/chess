require 'colorize'
require 'set'
require_relative 'pieces'
require 'byebug'

class Board
  CURSOR_DELTAS = {
                  "\e[A" => [-1, 0],
                  "\e[B" => [ 1, 0],
                  "\e[C" => [ 0, 1],
                  "\e[D" => [ 0,-1]
                  }

  attr_reader :cursor, :selected_piece, :grid

  def initialize(new_board = true)
    if new_board
      @cursor = [0, 0]
      @grid = generate_board
      set_positions
      @selected_piece = EmptySquare.new
    else
      # sentinel pattern
      # @sentinel = EmptySquare.new
      @grid = Array.new(8) { Array.new(8) { EmptySquare.new } }
    end
  end

  def [](pos)
    row, col = pos
    @grid[row][col]
  end

  def []=(pos, value)
    row, col = pos
    @grid[row][col] = value
  end

  def toggle_select
    @selected_piece = @selected_piece.empty? ? piece_at(cursor) : EmptySquare.new
  end

  def display
    system("clear")
    display_index_row
    display_rows
    display_index_row
    display_players_in_check
    bg_color = other_color(selected_piece.color)
    puts "selected piece: #{selected_piece.to_s.colorize(background: bg_color)}" unless selected_piece.empty?
  end

  def display_players_in_check
    puts "WHITE IN CHECK" if in_check?(:white)
    puts "BLACK IN CHECK" if in_check?(:black)
  end

  def display_index_row
     puts "    #{("a".."h").to_a.join("   ")}"
  end

  def update_square_sets

    if selected_piece.empty?
      @selected_piece_moves = [].to_set
      @attack_pieces = [].to_set
      opp_pieces = [].to_set
    else
      @selected_piece_moves = Set.new(selected_piece.valid_moves)
      opp_pieces = pieces_colored(other_color(selected_piece.color)).map do |piece|
        piece.pos
      end.to_set
    end
    @cursor_piece_moves = Set.new(piece_at(cursor).valid_moves)
    @attack_pieces = @selected_piece_moves & opp_pieces
  end

  def display_rows
    update_square_sets
    (0...8).each do |row_n|
      last_white = row_n.odd?
        print_row = []
        (0...8).each do |col_n|
          last_white = !last_white
          pos = [row_n, col_n]
          if cursor == pos
            color = :yellow
          elsif @attack_pieces.include?(pos)
            color = :red
          elsif @selected_piece_moves.include?(pos)
            color = :light_red
          elsif @cursor_piece_moves.include?(pos)
            color = :green
          elsif last_white
            color = :cyan
          else
            color = :magenta
          end
          print_row << piece_at(pos).to_s.colorize(background: color)
        end
        print_row.unshift("#{8 - row_n} ")
        print_row.push(" #{8 - row_n}")
        puts print_row.join
     end
  end

  def move_piece(move)
    origin, destination = move
    piece_at(origin).set_position(destination)
    ## move peice that was there logic
    piece_at(origin).set_moved if piece_at(origin).is_a?(Pawn)
    self[destination], self[origin] = piece_at(origin), EmptySquare.new
  end


  def map_deltas(action)
    future_cursor = cursor.map.with_index do |el, i|
      el + CURSOR_DELTAS[action][i]
    end
    return unless on_board?(future_cursor)
    @cursor = future_cursor
  end

  def on_board?(pos)
    pos.all? { |el| el.between?(0, 7) }
  end

  def occupied?(pos)
    !self[pos].empty?
  end

  #Returns the instance of the piece
  def piece_at(pos)
    self[pos]
  end

  def deep_dup
    new_board = Board.new(false)
    grid.each_with_index do |row, row_idx|
      row.each_with_index do |square, col_idx|
        pos = [row_idx, col_idx]
        new_board[pos] = square.dup(new_board)
      end
    end

    new_board
  end

  def checkmate?(color)
    return false unless in_check?(color)

    valid_moves = grid.flatten.select do |el|
      el.color == color
    end.map do |piece|
      piece.valid_moves
    end

    valid_moves.flatten.empty?
  end

  def in_check?(color)
    #only gets called on duped board
    move_arr = pieces_colored(other_color(color)).map { |el| el.moves }
    move_arr.any? { |move_set| move_set.include?(find_king(color)) }
  end

  def other_color(color)
    color == :white ? :black : :white
  end

  def pieces_colored(color)
    grid.flatten.select { |el| el.color == other_color(color) }
  end

  def find_king(king_color)
    grid.flatten.find { |el| el.is_a?(King) && el.color == king_color }.pos
  end

  private

    def generate_board
      board = []
      board << piece_set(:black)
      board << pawn_set(:black)

      4.times { board << empty_set }

      board << pawn_set(:white)
      board << piece_set(:white)

      board
    end

    def set_positions
      (0...8).each do |row|
        (0...8).each do |col|
          pos = [row, col]
          next if self[pos].empty?
          piece_at(pos).set_position(pos)
        end
      end
    end


    def pawn_set(color)
      Array.new(8) { Pawn.new(color, self) }
    end

    def piece_set(color)
      [
          Rook.new(color, self),
          Knight.new(color, self),
          Bishop.new(color, self),
          Queen.new(color, self),
          King.new(color, self),
          Bishop.new(color, self),
          Knight.new(color, self),
          Rook.new(color, self)
       ]
    end

    def empty_set
      Array.new(8) { EmptySquare.new }
    end
end

if __FILE__ == $PROGRAM_NAME
  b = Board.new
  b.display
  puts b.in_check?(:white)
end
