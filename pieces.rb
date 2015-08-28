require_relative 'moveables'
require 'colorize'

class Piece
  DIAGS = [
            [-1, -1],
            [ 1,  1],
            [ 1, -1],
            [-1,  1]
           ]

  ORTHOS = [
            [ 0, -1],
            [ 0,  1],
            [ 1,  0],
            [-1,  0]
           ]

	attr_reader :pos, :color, :board

	def initialize(color, board, pos = nil)
		@pos, @color, @board = pos, color, board
	end

	def set_position(pos)
		@pos = pos
	end

	def empty?
		false
	end

  def dup(duped_board)
    self.class.new(color, duped_board, pos.dup)
  end

  def not_in_check(moves)
    not_in_check = []
    moves.each do |destination|
      move = [pos, destination]
      next_board = board.deep_dup
      next_board.move_piece(move)
      not_in_check << destination unless next_board.in_check?(color)
    end

    not_in_check
  end

  def opposing_color
    color == :white ? :black : :white
  end
end


class King < Piece

	include Steppable

	def to_s
    " \u265A  ".colorize(color)
	end

	def moves
		generate_moves(ORTHOS + DIAGS)
	end

  def valid_moves
    not_in_check(generate_moves(ORTHOS + DIAGS))
  end
end

class Queen < Piece
	include Slideable

	def to_s
    " \u265B  ".colorize(color)
	end

	def moves
		generate_moves(ORTHOS + DIAGS)
	end

  def valid_moves
    not_in_check(generate_moves(ORTHOS + DIAGS))
  end
end

class Bishop < Piece
	include Slideable

	def to_s
    " \u265D  ".colorize(color)
	end

	def moves
		generate_moves(DIAGS)
	end

  def valid_moves
    not_in_check(generate_moves(DIAGS))
  end
end

class Rook < Piece
	include Slideable

	def to_s
    " \u265C  ".colorize(color)
	end

	def moves
		generate_moves(ORTHOS)
	end

  def valid_moves
    not_in_check(generate_moves(ORTHOS))
  end
end


class Knight < Piece
	KNIGHT_STEPS = [
                    [ 1,  2],
                    [ 1, -2],
                    [-1,  2],
                    [-1, -2],
                    [ 2,  1],
                    [ 2, -1],
                    [-2, -1],
                    [-2,  1]
                  ]

	include Steppable

	def to_s
		" \u265E  ".colorize(color)
	end

	def moves
		generate_moves(KNIGHT_STEPS)
	end

  def valid_moves
    not_in_check(generate_moves(KNIGHT_STEPS))
  end
end

class Pawn < Piece
	attr_reader :moved
  PAWN_MOVES = {
      :white => [
        [[-1, 0], [-2, 0]], [[-1, -1], [-1, 1]]
      ],
      :black => [
        [[1, 0], [2, 0]], [[1, -1], [1, 1]]
      ]
  }

	def initialize(color, board, pos = nil, moved = false)
		super(color, board, pos)
		@moved = moved
	end

  def set_moved
    @moved = true
  end

	def to_s
    " \u265F  ".colorize(color)
	end

  def dup(duped_board)
    Pawn.new(color, duped_board, pos.dup, moved)
  end

  def moves
    moves = []
    steps, attacks = PAWN_MOVES[color]
    steps.each do |step|
      if step.any? { |x| x.abs == 2 }
        intermediate_delta = [step[0] / 2, step[1]]
        small_step = pos.map.with_index { |el, i| el + intermediate_delta[i] }
        next if moved || board.occupied?(small_step)
      end
      
      next_step = pos.map.with_index { |el, i| el + step[i] }
      next unless board.on_board?(next_step)
      moves << next_step unless board.occupied?(next_step)
    end

    attacks.each do |attack|
      next_attack = pos.map.with_index { |el, i| el + attack[i] }
      next unless board.on_board?(next_attack)
      if board.piece_at(next_attack).color == opposing_color
        moves << next_attack
      end
    end

    moves
  end

  def valid_moves
    not_in_check(moves)
  end
end


class EmptySquare
  def to_s
    "    "
  end

  def empty?
    true
  end

	def set_position(pos)
	end

	def color
		false
	end

	def moves
		[]
	end

  def valid_moves
		[]
	end

  def dup(duped_board)
    EmptySquare.new
  end
end
