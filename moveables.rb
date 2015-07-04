require 'byebug'

module Slideable
  def generate_moves(move_deltas)
    moves = []
    move_deltas.each do |delta|
      wall_hit = false
      current_pos = pos.dup
      until wall_hit
        next_pos = current_pos.map.with_index { |el, i| el + delta[i] }
        if !board.on_board?(next_pos) || board.piece_at(next_pos).color == color
          wall_hit = true
        elsif board.piece_at(next_pos).empty?
          moves << next_pos
          current_pos = next_pos
        else ## it must be an opposing player piece
          moves << next_pos
          wall_hit = true
        end
      end
    end

    moves
  end

end

module Steppable

  def generate_moves(steps)
    moves = []
    steps.each do |step|
      next_pos = pos.map.with_index { |el, i| el + step[i] }
      if board.on_board?(next_pos) && board.piece_at(next_pos).color != color
        moves << next_pos
      end
    end

    moves
  end

end
