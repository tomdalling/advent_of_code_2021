#!/usr/bin/env ruby -Ilib

require 'byebug'

class Room < Struct.new(:slots, :hall_pos, :type, keyword_init: true)
  def self.build(hall_pos, type_sym, amp_syms)
    new(
      hall_pos: hall_pos,
      type: Amphipod.public_send(type_sym).type,
      slots: amp_syms.map { Amphipod.public_send(_1) },
    )
  end

  def dup
    self.class.new(
      slots: slots.dup,
      hall_pos: hall_pos,
      type: type,
    )
  end

  def empty?
    slots.all?(&:nil?)
  end

  def full?
    slots.none?(&:nil?)
  end

  def solved?
    full? && slots.all? { _1.type == type }
  end

  def accepts?(amp)
    return false unless amp.type == type
    return false if full?
    return false if slots.any? { _1 && _1.type != type }
    true
  end

  def can_leave?
    return false if empty?
    return false if slots.all? { _1.nil? || _1.type == type }
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
    room_steps = room_pos + 1

    hall_steps + room_steps
  end

  def valid_for?(puzzle)
    case direction
    when :in
      room_hall_pos, room_pos = dest
      room = puzzle.room(room_hall_pos)
      return false unless puzzle.hall[source] # amp must exist in hall
      return false unless room.slots[0..room_pos].all?(&:nil?) # must go to back of room
      return false unless room.slots[(room_pos+1)...].none?(&:nil?) # must go to back of room
      return true
    when :out
      room_hall_pos, room_pos = source
      room = puzzle.room(room_hall_pos)
      return false unless puzzle.hall[dest].nil? # hall must be empty
      return false unless room.slots[0...room_pos].all?(&:nil?) # must be able to leave room
      return false unless room.slots[room_pos...].none?(&:nil?) # rest of room is filled up
      return true
    else
      raise NotImplementedError
    end
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
    rooms.all? { _1.nil? || _1.solved? }
  end

  def to_s
    <<~TEXT
      #############  cost: #{cost}
      ##{hall.map{ (_1 || '.').to_s }.join}#
      ####{rooms.map{_1.slots[0]}.map{ (_1 || '.').to_s }.join('#')}###
      ####{rooms.map{_1.slots[1]}.map{ (_1 || '.').to_s }.join('#')}###
      ####{rooms.map{_1.slots[2]}.map{ (_1 || '.').to_s }.join('#')}###
      ####{rooms.map{_1.slots[3]}.map{ (_1 || '.').to_s }.join('#')}###
        #########
    TEXT
  end

  def room(hall_pos)
    rooms[hall_pos]
  end

  def applying_move(move)
    dup.tap do |new_puzzle|
      case move.direction
      when :out
        room = new_puzzle.room(move.source.first)
        room_pos = move.source.last
        amp = room.slots[room_pos]
        # raise "AAA" unless amp
        # raise "BBB" unless hall[move.dest].nil?

        new_puzzle.hall[move.dest] = amp
        room.slots[room_pos] = nil

        new_puzzle.cost += move.steps * amp.energy_per_step
      when :in
        room = new_puzzle.room(move.dest.first)
        room_pos = move.dest.last
        amp = hall[move.source]
        # raise "CCC" unless amp
        # raise "DDD" unless room.slots[room_pos].nil?

        room.slots[room_pos] = hall[move.source]
        new_puzzle.hall[move.source] = nil

        new_puzzle.cost += move.steps * amp.energy_per_step
      else
        raise NotImplementedError
      end
    end
  end

  def possible_moves
    (possible_moves_out_of_rooms + possible_moves_into_rooms)
      # .tap do |moves|
      #   moves.each do |m|
      #     raise "BADMOVE" unless m.valid_for?(self)
      #   end
      # end
  end

  def possible_moves_out_of_rooms
    rooms.compact.select(&:can_leave?).flat_map do |r|
      hall_positions_reachable_from(r.hall_pos).map do |hall_pos|
        room_pos = r.slots.index { _1 }
        Move.new(direction: :out, source: [r.hall_pos, room_pos], dest: hall_pos)
      end
    end
  end

  def possible_moves_into_rooms
    hall.each_with_index.map do |amp, hall_pos|
      next unless amp

      dest_room = rooms.find { _1 && _1.type == amp.type }
      next unless dest_room.accepts?(amp)

      if room_reachable?(dest_room, hall_pos)
        room_pos = dest_room.slots.rindex { _1.nil? }
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
    rooms[hall_pos]
  end
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
      # puts "Reached new low: #{lowest_so_far}"
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
#   #D#C#B#A#
#   #D#B#A#C#
#   #C#A#B#C#
#   #########
puzzle = Puzzle.new(
  cost: 0,
  hall: Array.new(11) { nil },
  rooms: [
    nil,
    nil,
    Room.build(2, :a, %i[d d d c]),
    nil,
    Room.build(4, :b, %i[d c b a]),
    nil,
    Room.build(6, :c, %i[b b a b]),
    nil,
    Room.build(8, :d, %i[a a c c]),
    nil,
    nil,
  ]
)

# most paths have no solution, so we can hard-code some of them
SOLVED_PATH = [25, 21]
LOWEST_COST_SEEN = 45626
SOLVED_PATH.each do |move_idx|
  puzzle = puzzle.applying_move(puzzle.possible_moves.fetch(move_idx))
end

forks_left = {}
puzzle.possible_moves.each_with_index.map do |move, idx|
  pid = Process.fork do
    puts "Starting #{idx}/#{Process.pid}"
    next_puzzle = puzzle.applying_move(move)
    lowest_cost = lowest_solution_cost(next_puzzle, lowest_so_far: LOWEST_COST_SEEN)
    prefix = lowest_cost ? '!!!!!!' : ">"
    puts if lowest_cost
    puts "#{prefix} Process #{idx}/#{Process.pid}: #{lowest_cost || 'NO SOLUTION FOUND'}"
    puts if lowest_cost
    exit
  end
  forks_left[pid] = idx
end.each do
  puts "Waiting for #{forks_left.values.sort}"
  Process.wait
  forks_left.select! do
    begin
      Process.kill(0, _1)
      true
    rescue Errno::ESRCH
      false
    end
  end
end

puts "ALL DONE #{forks_left.inspect}"

__END__
Starting 0/40697
Starting 1/40698
Starting 2/40699
Starting 3/40700
Starting 4/40701
Starting 5/40702
Starting 6/40703
Starting 7/40704
Starting 8/40705
Starting 9/40706
Starting 10/40707
Starting 11/40708
Starting 12/40709
Starting 13/40710
Starting 14/40711
Starting 15/40712
Starting 16/40713
Starting 17/40714
Starting 18/40715
Starting 19/40716
Starting 20/40717
Starting 21/40718
Starting 22/40719
Starting 23/40720
Starting 24/40721
Starting 25/40722
Starting 26/40723
Starting 27/40724
Process 00/40697: NO SOLUTION FOUND
Process 01/40698: NO SOLUTION FOUND
Process 02/40699: NO SOLUTION FOUND
Process 03/40700: NO SOLUTION FOUND
Process 04/40701: NO SOLUTION FOUND
Process 05/40702: NO SOLUTION FOUND
Process 06/40703: NO SOLUTION FOUND
Process 07/40704: NO SOLUTION FOUND
Process 08/40705: NO SOLUTION FOUND
Process 09/40706: NO SOLUTION FOUND
Process 10/40707: NO SOLUTION FOUND
Process 11/40708: NO SOLUTION FOUND
Process 12/40709: NO SOLUTION FOUND
Process 13/40710: NO SOLUTION FOUND
Process 14/40711: NO SOLUTION FOUND
Process 15/40712: NO SOLUTION FOUND
Process 16/40713: NO SOLUTION FOUND
Process 17/40714: NO SOLUTION FOUND
Process 18/40715: NO SOLUTION FOUND
Process 19/40716: NO SOLUTION FOUND
Process 20/40717: NO SOLUTION FOUND
Process 21/40718: NO SOLUTION FOUND
Process 22/40719: NO SOLUTION FOUND
Process 23/40720: NO SOLUTION FOUND
Process 24/40721: NO SOLUTION FOUND

Process 26/40723: NO SOLUTION FOUND
Process 27/40724: NO SOLUTION FOUND
