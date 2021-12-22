#!/usr/bin/env ruby -Ilib

PLAYERS = [:p1, :p2]
BOARD_SIZE = 10

def roll
  rand(1..3)
end

def winner(scores)
  scores.find{ _2 >= 21 }&.first
end

def loser(scores)
  return nil unless winner(scores)
  (scores.keys - [winner(scores)]).first
end

def roll_probabilities
  options = (1..3).to_a
  options.product(options, options).map(&:sum).tally.sort_by(&:first).to_h
end


(3..9).each do |offset|
  puts "== Offset #{offset} ===="
  0.upto(9) do |starting_pos|
    positions = {
      p1: starting_pos,
      # p2: 2,
    }

    scores = {
      p1: 0,
      # p2: 0,
    }

    turns = 0

    until winner(scores)
      positions.keys.each do |p|
        # offset = roll + roll + roll
        turns += 1
        pbefore = positions[p]
        positions[p] = (positions[p] + offset) % BOARD_SIZE
        scores[p] += positions[p] + 1
        # puts "#{p} + #{offset} (from #{pbefore} to #{positions[p]})"
        break if winner(scores)
      end
    end

    puts "  Won in #{turns} turns from position #{starting_pos+1}"
  end
end

pp scores

pp roll_probabilities
pp roll_probabilities.values.sum
