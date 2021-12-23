#!/usr/bin/env ruby -Ilib

require 'byebug'

class Room < Struct.new(:back, :front, :hall_pos, :type, keyword_init: true)
  def empty?
    front.nil? && back.nil?
  end

  def full?
    front && back
  end

  def solved?
    full? && front.type == type && back.type == type
  end

  def accepts?(amp)
    return false if full?
    return false unless amp.type == type
    return false if back && back.type != type
    true
  end

  def can_leave?
    return false if empty?
    return false if [back, front].compact.all? { _1.type == type }
    true
  end
end

class Amphipod < Struct.new(:type, :energy_per_step, keyword_init: true)
  def self.a
    new(type: "Amber", energy_per_step: 1)
  end
  def self.b
    new(type: "Bronze", energy_per_step: 10)
  end
  def self.c
    new(type: "Copper", energy_per_step: 100)
  end
  def self.d
    new(type: "Desert", energy_per_step: 1_000)
  end

  def initialize(...)
    super
    freeze
  end

  def to_s
    type[0]
  end
end

class Move < Struct.new(:direction, :source, :dest, keyword_init: true)
  def steps
    room_side, hall_pos = room_and_hall
    room_hall_pos, room_pos = room_side

    hall_steps = (hall_pos - room_hall_pos).abs
    room_steps =
      case room_pos
      when :front then 1
      when :back then 2
      else raise NotImplementedError
      end

    hall_steps + room_steps
  end

  private

    def room_and_hall
      case direction
      when :in then [dest, source]
      when :out then [source, dest]
      else raise NotImplementedError
      end
    end
end

class Puzzle < Struct.new(:rooms, :hall, :cost, keyword_init: true)
  def dup
    self.class.new(
      rooms: rooms.map(&:dup),
      hall: hall.dup,
      cost: cost,
    )
  end

  def solved?
    rooms.all?(&:solved?)
  end

  def to_s
    <<~TEXT
      #############  cost: #{cost}
      ##{hall.map{ (_1 || '.').to_s }.join}#
      ####{rooms.map(&:front).map{ (_1 || '.').to_s }.join('#')}###
        ##{rooms.map(&:back).map{ (_1 || '.').to_s }.join('#')}#
        #########
    TEXT
  end

  def room(hall_pos)
    rooms.find { _1.hall_pos == hall_pos }
  end

  def applying_move(move)
    dup.tap do |new_puzzle|
      case move.direction
      when :out
        room = new_puzzle.room(move.source.first)
        room_pos = move.source.last
        amp = room[room_pos]
        # raise "AAA" unless amp
        # raise "BBB" unless hall[move.dest].nil?

        new_puzzle.hall[move.dest] = amp
        room[room_pos] = nil

        new_puzzle.cost += move.steps * amp.energy_per_step
      when :in
        room = new_puzzle.room(move.dest.first)
        room_pos = move.dest.last
        amp = hall[move.source]
        # raise "CCC" unless amp
        # raise "DDD" unless room[room_pos].nil?

        room[room_pos] = hall[move.source]
        new_puzzle.hall[move.source] = nil

        new_puzzle.cost += move.steps * amp.energy_per_step
      else
        raise NotImplementedError
      end
    end
  end

  def possible_moves
    possible_moves_out_of_rooms + possible_moves_into_rooms
    # possible_moves_out_of_rooms
  end

  def possible_moves_out_of_rooms
    rooms.select(&:can_leave?).flat_map do |r|
      hall_positions_reachable_from(r.hall_pos).map do |hall_pos|
        room_pos = r.front ? :front : :back
        Move.new(direction: :out, source: [r.hall_pos, room_pos], dest: hall_pos)
      end
    end
  end

  def possible_moves_into_rooms
    hall.each_with_index.map do |amp, hall_pos|
      next unless amp

      dest_room = rooms.find { _1.type == amp.type }
      next unless dest_room.accepts?(amp)

      if room_reachable?(dest_room, hall_pos)
        room_pos = dest_room.back.nil? ? :back : :front
        Move.new(direction: :in, source: hall_pos, dest: [dest_room.hall_pos, room_pos])
      end
    end.compact
  end

  def room_reachable?(room, from_hall_pos)
    from_pos, to_pos = [from_hall_pos, room.hall_pos].sort
    (hall[from_pos..to_pos].count { _1 }) == 1 # only one amp in from_hall_pos
  end

  def hall_positions_reachable_from(start_pos)
    [].tap do |results|
      # walk left
      pos = start_pos
      loop do
        pos -= 1
        break if pos < 0
        break if hall[pos] # blocked by another amp
        results << pos unless doorway?(pos)
      end

      # walk right
      pos = start_pos
      loop do
        pos += 1
        break if pos >= hall.size
        break if hall[pos] # blocked by another amp
        results << pos unless doorway?(pos)
      end
    end
  end

  def doorway?(hall_pos)
    rooms.any? { _1.hall_pos == hall_pos }
  end
end

def puts_path(path)
  path.each do |(puzzle, move)|
    puts puzzle
    puts
    pp move
    puts
  end
  nil
end

$depth = 0
$iterations = 0
PRINT_DEPTH = 3
def lowest_solution_cost(puzzle, lowest_so_far: nil)
  if lowest_so_far && puzzle.cost > lowest_so_far
    return lowest_so_far + 1 # don't explore this path if it's already too expensive
  end
  # $iterations += 1
  # puts "Iteration #{$iterations}" if $iterations % 1000 == 0

  # puts "=== #{$depth} ==="
  # puts puzzle
  if $depth > 40
    puts ">"*80
    puts_path(path)
    abort "YEEP"
  end
  return puzzle.cost if puzzle.solved?

  # brute force dat
  possible_moves = puzzle.possible_moves
  if $depth < PRINT_DEPTH
    # puts ("  " * $depth) + "Starting #{possible_moves.size} possibilities (< #{lowest_so_far})..."
  end

  possible_moves.each_with_index.map do |move,idx|
    $depth += 1
    lowest = lowest_solution_cost(
      puzzle.applying_move(move),
      lowest_so_far: lowest_so_far,
    )
    if !lowest_so_far || (lowest && lowest < lowest_so_far)
      lowest_so_far = lowest
    end
    $depth -= 1
    lowest
  end.compact.min.tap do |mincost|
    if $depth < PRINT_DEPTH
      # puts ("  " * $depth) + "Done (#{mincost})"
    end
  end
end

# #############
# #...........#
# ###D#D#B#A###
#   #C#A#B#C#
#   #########
puzzle = Puzzle.new(
  cost: 0,
  hall: Array.new(11) { nil },
  rooms: [
    Room.new(hall_pos: 2, front: Amphipod.d, back: Amphipod.c, type: Amphipod.a.type),
    Room.new(hall_pos: 4, front: Amphipod.d, back: Amphipod.a, type: Amphipod.b.type),
    Room.new(hall_pos: 6, front: Amphipod.b, back: Amphipod.b, type: Amphipod.c.type),
    Room.new(hall_pos: 8, front: Amphipod.a, back: Amphipod.c, type: Amphipod.d.type),
  ]
)

puzzle.possible_moves.each_with_index.map do |move, idx|
  Process.fork do
    puts "Starting #{idx}/#{Process.pid}"
    next_puzzle = puzzle.applying_move(move)
    puts "Process #{idx}/#{Process.pid}: #{lowest_solution_cost(next_puzzle) || 'NO SOLUTION FOUND'}"
    exit
  end
end.each do |pid|
  puts "Waiting for #{pid}"
  Process.wait(pid)
end

puts "ALL DONE"
