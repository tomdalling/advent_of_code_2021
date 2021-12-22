#!/usr/bin/env ruby -Ilib

PLAYERS = [:p1, :p2]
BOARD_SIZE = 10

$last_roll = 0
$num_rolls = 0

def roll
  $num_rolls += 1
  $last_roll += 1
  $last_roll = 1 if $last_roll > 100
  $last_roll
end

positions = {
  p1: 9,
  p2: 2,
}

scores = {
  p1: 0,
  p2: 0,
}

def winner(scores)
  scores.find{ _2 >= 1000 }&.first
end

def loser(scores)
  return nil unless winner(scores)
  (scores.keys - [winner(scores)]).first
end

until winner(scores)
  PLAYERS.each do |p|
    offset = roll + roll + roll
    positions[p] = (positions[p] + offset) % BOARD_SIZE
    scores[p] += positions[p] + 1
    break if winner(scores)
  end
end

pp scores[loser(scores)] * $num_rolls
