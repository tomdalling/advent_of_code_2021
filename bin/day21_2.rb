#!/usr/bin/env ruby -Ilib

class Game
  BOARD_SIZE = 10
  MOVE_PROBS = {3=>1, 4=>3, 5=>6, 6=>7, 7=>6, 8=>3, 9=>1} # out of 27
  WIN_SCORE = 21

  attr_reader :scores, :positions, :next_turn

  # Player 1 starting position: 10
  # Player 2 starting position: 3
  def initialize(positions: [9,2], next_turn: 0, scores: [0,0])
    @positions = positions
    @next_turn = next_turn
    @scores = scores
  end

  def after_move(distance)
    new_positions = positions.dup
    new_positions[next_turn] = (positions[next_turn] + distance) % BOARD_SIZE

    new_scores = scores.dup
    new_scores[next_turn] += new_positions[next_turn] + 1

    self.class.new(
      positions: new_positions,
      next_turn: (next_turn + 1) % positions.size,
      scores: new_scores,
    )
  end

  def finished?
    not winner.nil?
  end

  def winner
    scores.each_with_index do |sc, player_idx|
      return player_idx if sc >= WIN_SCORE
    end

    nil # game not over yet
  end

  def win_probabilities
    return {winner => 1} if finished?

    MOVE_PROBS.map do |roll, occurrences|
      after_move(roll).win_probabilities.transform_values { _1 * occurrences }
    end.reduce do |p1, p2|
      p1.merge(p2) do |_, v1, v2|
        v1 + v2
      end
    end
  end
end

# pp Game.new.win_probabilities

probs = {1=>49950658789496, 0=>93726416205179}
pp probs.to_a.sort_by(&:last)
