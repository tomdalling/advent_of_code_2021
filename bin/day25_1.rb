#!/usr/bin/env ruby -Ilib

require 'grid'
require 'byebug'

class Cumbies < Grid
  def step
    direction_step('>', 1, 0) +
      direction_step('v', 0, 1)
  end

  def direction_step(type, vx, vy)
    moves = []
    each_cell do |ch, x, y|
      next unless ch == type
      dx, dy = wrap_coord(x + vx, y + vy)
      if self[dx, dy].nil?
        moves << [x, y, dx, dy]
      end
    end

    moves.each { apply_move(*_1) }

    moves.size
  end

  def wrap_coord(x, y)
    [x % column_count, y % row_count]
  end

  def apply_move(from_x, from_y, to_x, to_y)
    raise "WRF" unless self[to_x, to_y].nil?
    raise "WRF2" unless self[from_x, from_y]

    self[to_x, to_y] = self[from_x, from_y]
    self[from_x, from_y] = nil
  end

  def to_s
    ("-" * column_count) + "\n" +
      rows.map do |cells|
        cells.map do |c|
          c || '.'
        end.join
      end.join("\n")
  end
end

grid = Cumbies.from_rows(
  DATA.lines.map do |line|
    line.strip.chars.map do |ch|
      case ch
      when '.' then nil
      when '>', 'v' then ch
      else raise NotImplementedError
      end
    end
  end
)

step = 0
loop do
  step += 1
  moves = grid.step
  puts "Step #{step}: #{moves} moves"
  break if moves == 0
end

__END__
>.>v.v.>...>v.>>v.>..vv>>v>v....>.v..>v..v>>>>..>>.....>....>..vv..v>.v.vv.>v......>>.>vv>vv..v>..v......vvv..v...vv.>...vv...v>..>..>v>.>.
....v>.>..v.v>...v.>...v..v.>.>>>..v>>..vv>.v....v..v...>>>..>...v....v>>.v>>.v.>vvv..>...>...v..v>..v.v..v...vv.>.>vv.>.v..>>v...v.>>>v..>
...v.>vv.>.v..>..v....>vv.>...v.vv>vv..vv.vv...>>..v>vvv..vv...............vv...>v>>v..>.v.>vv...>>...v>v.v.>>>.>....>.>.v....>.>v.>>..v.v.
.....vv.vv....v>vvv..v.v>>v.v..vv>.>..v........>>...>.>>>....>>.v>.v..>v>..v...>>........v>>>v>.v......vv..vv...>..>.>.>vv>v>vv...v.vv>>v..
..vv.v..>.vv>.v.vvvv>v..>v..v>.>>......v...v.>v>>>..>.v...>.v..>v..v>.>...v..v>>.vv.vv..v...>.....>.......v..v.>..>...>v.vvv.....>v.v..>>.>
v.v.>.v.>.v..v.v>v..v.>.>vv...>......>...>..>.v>..v.v..v.>...>.v.>>.v.......v>vvv>.v..>>>..v..>.>>v>v>>v.v.......>...vv..>..>v......v..v...
v.>>vv>v..>.>.>.>..v>>v.v>vvv...v.>v...>..>vvv.v.>.>.>.>.....v>..>..v.vv>v.>.v.v>.v>vv...v...>.v.v...>v.>>.>v..v>v.>.>...>v>.>..>>>.vv.v.>>
..>>.>>.v.....v>.v.v......v>>>>.v.>>.v.v>v.v>>.>>.>....v>.v>>>>..vv..>>....>>.>...vv.>v>vv..v...>.vv.vv....vvv>.v.>....>v.>.v...v.v>vv..>.v
vv.>..v>v.>v.vv>..v.v..>>>>>v....v.vvv>>.>...>vv..>.v..>...>..v..>>v>.>..>v..>...>..v>..vvv>..v...v....>v..vv......vv.v>.v..v>....>...>...v
vv>v.v.vv.>>.v.>v....vv..>>....vvv.>..>>....vv..>v>...vvv.v.vv>>.>.vv.>.>.>.>.....>v.v>vv.v.>.>v.>>v>...>..>v>..>vvvv...v.v....v>.....>....
...>.v.>v.>...v.>v..vv.>..v.....>>v>>>>v.>..v.>.vv.>>..>.>v.>>v...>.v..v>>v..v>.v.>>v>>>..v>..vv..>.>>v.v>v..>.>vv..>...>v..v........vvv.>.
.>..>v.>>...>vv.v>v.>v>......>.>>>.v...v.>>...>.vv.v..>vv>v.>>.....>>v>v>v...v>...vv...>v>>..v..>.>.....v>...v........>.vv.>>v...v>.v.>v...
v...>.vv.......vvv...>>.>>vvv...v>..>v.>>vv.>...>v..>..vv.>v>v>v>.v>..v>v..>..>v.>v>>....v.>..v.>v>.vv.>v.>vv>...v>vv>.v.vvv...>.v>v...v..>
.v...>>.v>.>.v.vv.v.>....>.v.v>>..>.>.v>>v>vvvvvv.vvv>v.v.v..>v>.vv..>...>vv.v.>...v.vv.v.>vv.v.v.>...v>..>..v>..v>v>>v.v..v.>vvvv>v.vvv.v.
>v.v.v.vv>v..v>v.v...>>vvv...>.v.vv...>.v..vv.vvv.....v..>..>...>.......v>.>v.v.v..>.....vv...v.......>>>v>..>>.......v>...>.>vv.>.>>v>..v.
.vv.vv.>>..>.v..v..>.>...>>.>>v.>.>..>..>.>.vv.v.>.>v.>.v..v..vvv..v>.>.>.>..v..>v..>...vv..vv...>..>>v>..>>v.....>vv.>..v>.vv>v.vv....>v>>
>>.>>>.>.vvv>...v>vv.>.v....v.>>..>vvv..>>.v...vv.>..>.v.>>.v>..>>.vv..>.>>..>vv>>v>...>vv.>.>>>...>.>.>>.v>v>.v>vv>.v.vv...>v>v.vv.>>.vvv.
>v.>.v..v.vv..>v.....v.>vvv.>.>>vv..>>.vv..v.v>.>..v>v...>.>.v.>vv>v...v.>v.v...>v.v...v>.v.>..>.>v.>v...v..v..vv.v.v.>vv>>.>.>v.v.>.>v>...
..vv>.>.v>vvv.>....>...>.>>>.>.>v>v..>.v....>v...v>..>....>>>v>.v>.v.v....v.>>v>>v>>.>v...>>.vv..>..>..>..>>.>...v.>v.v>>.>v...>..>v.>.....
>v.v.v...>>>vvv.>>.>>>>>.vv>.>v....>>.....>v.vv.....>....vv..v.v>.v....v>>>.v.....v...v.>.>>v>....v>.vvv..>v.v....>...vv..vvv>.....v....vv.
vv.v>>v....v.>.>>v.v.v.......v.>...>.>>vvv.v.v..>....>v.>v.>>>vv>v>..>.....>...>>>.v.>..vv>.v..v..v.>.....>.v.v...>..v.v.....>...>>>...>.v>
v.>.v>.....vvvv...>.vvv.>.vv..>..>>..vvv.v...v.v.>>.>v>.>v....v.>>.>>....v..v>.>...>>..v.vvv..>.v...>.>v...v..>.v...>..>..v.>.v>..v..>>.>..
..v>v.v...>vv..>>.........vv..>v....v.>vv.>>.v..v...>...v>v.v...>>>>.>.>.vv...v>>vv>>.....>>.vv.vv>v>vv..vv.>v.v.....>.vvv>.......>...>v.v.
..v....vvv>.v.v>....v..vvv..>>v>....v.v>.v.>..>v...>..v>>..>.>...v..v..v.vv>.>..>..>vv..v.v>v>..>..vv>>.vv>.v>v.>..v>..v.vvv>>>>.v...>v>..>
.vv.vv.vv...>.v>v..vv.>.......>.>>v.v.>>v>..v.v.>....v>...>..v>...v.vv>.v..vv......v>vv.v.v....vv...>...>v>...>...v.....>.v.v.v......>>v.v.
>..v.v..v>.>v..>v>..>....>..vv...v.>vv.....>v>...>.....v>>.vv.vv.v..>.>v..>v..>.>vv...>>.>>>.>>>...........>.>.v.>v>>...v>v.>.vvv>v>v.v.v..
.v..>>..>v>..v.v....>..vv>vv.v..>v..v..v..v...vvv>>v>vvv>.v...v.>v.v>vv>v.v>..v.v..v>>>v..vvv>>..v..>....v...>.>v..v.>>>.>.>v......>vvv>...
....>vvvv....v>v.>v.v>>v.....v...vvv>.v....vvvv.>v.>..v>>v>vv.>>.>....v>....>.>v.>.>>>vv...>.v...v.v>vv...v>.vvv>v>.vv.v.>....v.>..vv...>..
.>>vv.>>.>.>..vv>.v>..vvv.....v>.v.>.v.......v.vvvvv.v.>>....>.>.>>>v>...>>>v...v.>>>>>...v>v..>..>...v..>.>.>v.>v>...vv...>..vv.v..v..v>>.
v....v>.....>>>.>v..v.v>>.>vvv..>v>>>.vv>..>.>>v...>..>..v...v>..v.v...>.>v......>>vv>.vv..>.>>>v.v.vvv..>...>.>..v..v....>v...>.>.vvv>.>.>
.v.>>.>...>>v.vvv..v>vv.v.>>v>vv>.>v......v>>v>vv.>.>.vv>.>.>.>.....v>>.v>v>.>v..>..vv..>v>>>>>.>.>v.>...v.v>..>.vv..v>v>..vv>..>.....>>>.>
....>v........>v.v...>v..vv>>.v.>..v..>>v>.....>..>vvv>.vv.v.>.>v.v>.v.>v.>..>v.v>>...>.>.v.>.>v..>>....vvv.>>.>.v.>>v....v>..v>.v.>...>.>v
..v..>..v>.v.>>v....>v.>vv.>v....>v.v.v.>....vv>....v.v.v..v.v.vv...>.>>>.>.>.v>.v.v...v>.>..>.>.v..v...>vv>>v......v.>..>..>>>.....vv..v.>
v.v>v.>>vvvv.>.v>v...v.>.......>v.vv....>>v.v....v....v..>>>>>.vvv.>.>>.v>>.v>>vv.>v>..>.......>.>.vv>..>.>.>>...>.....>>.v.v..>v>v>.>v>v>.
>>>>.v.vv.>...>>.>....v.v>..vv>.vv>>vv.>..vv>.>.v>>...v....v.vvv>v.>.v.vvv.v.v..v.v.v....vv>..>v.....>>>>v>.>v.vv..vv.v.....vv..v>..v.v..>.
>>..v...v.>>>..vv.v..>>.vv.v....>.>>>>>>>v.v.>....v>.v...v>.v>v.>..>.v.v>..v....>...v....>.v>.v>.v>>>.>.>>.v>....>v.>>.....>..vv.>>v>>.>...
v.>>>v......>...>>..vv>>>>v>>v.>v...v>>.v..vv.v.vvv>>v.>v.vv.vv...v>>.>..>v.....>>>.v..vv.>>.>>>..v>>>.....v>..>.>v.v>vvv.v...v>>.>>.>>>..>
.v>..>v>v..v..>v>>v.v...vvvv.v.v....vvvvv..vv.>......>>...v...v.>..v...>vvv..v>v.>>vv.>.v>>.....>v.v..v.>>....v>>vv>.>.v.v>...>.>.>.v>.>v>.
.>.>..v.>.>.v.vvv.v.vv.v>v.v.>..>>.v..v.>.v>.>.vv>>>>...v..v.>....v..>>.vv..>>.>>v.>v.v>.>v.v..>.vv.vvv.vv>...v.v>vvv>.v.>vv>>.>vvvvvvv.v.>
>.>.>vv>>>vv..>>.vv.>..v.v>>>..vv..>v.vv..>>.>>.v....v>..v.>>>vv.v.>.v>.....v..vv>...>vv.v...>...>..>..>>>v....v.vv.>v..>v>....>...>>v>...v
...v........v>v>....v>...>.>v>v>v...>.v>.>.>..>.>.vv.>.>..v.....>v...vvv..v>>..>>>>...vv..v.>>v.vv>v.>...>....>.>..v.v...v..>>v.>.>vv>.v>>.
....vv.>>v.v>vv....>...v...>vv..v.vv>.vvv.>v.>.v.....vv>...v.v.v...>.v.>....v>>.v..>v>.v>.vvv>..>>.vv.v>v>........>.v>.>.>v...v..>.v..>>v>v
v...>..v.>.v......v...vvvv..v.>..vv>>>>v.......>.>.......>.v..>..v>..v..v.>v.v..>>..v>v.>>v..v.vv.vv>.v.>>vv....>...>v.v.vv..v>>..v.vv>.>..
.v.vvv...v.>v>v>.vv>>vvv.v.>.v.vv>v..v.vv.>v>..v.....>.v>v......v..v.v..v....v>>v..vv..>v...>>..v...>..v>v.>v>>v..v..>v....v.v.>v>.v..>>.v>
vvv..v.>....vv.vv.>>...vvvv.vvvv....>>vv...v>>v...v..>.>>...>.v.v....>vv.v.>..>...>.>>v....>.>..>v.>...>>vvvv......>vv>>.>..>.>>v.v....>..>
>v.v...>....>>.>.vvv...>>..v>>....>......>v>.>v..v.>v.vvv..>.>.>.>>.v.v>....>...v>.v>..>.vv..v.>...v>v.>.>.>v>....>vv.>..>>.>...v.>....>.>v
>.v>>>>...vv.v.>v.>v>..>..v...>..>v.>.>...vv.>.>.>...>.>..vv..>v..vv.>....>.v>v>.>v...>...>.>v....v>v...>>.....>.>..>vv.....v>..>...v.>..v.
v....v>..vvv....>..>.v...>....vv.v>.v>..>.vv.>v>..>..>>>vv...v.>vv>...>.vv.v>vv>v>v>....>...>..>vv>>v>....>...vvv>v.v.>.>.vv>.vvv>vv...vv>v
..v..>.v.....v.>.....>vv.>.vv>v..v.>..v>....>.>>..>>>v>.>v>>....>vv>>.vv.v.v.>vv>.>.v...>>>..v>...>v>.v...>>.vv....v..>.>..v.v...v>..v>v.>>
....>v..v..v>..v>v.....v..>.v.>v.vv>.v>>>>....>v.vvv>.....v..>..>.v>>..>.vv.>.v.v>...v>>.v.v>v.>..v>vvv>>>>..>.v.>..v.v....vv>v.>>.vv>.>..v
vv>.....v...>.>>v>.vv.>v>.v..vv>......v.v.>..v.....>v>.>v.v>v.v.....>vv......>..>.>.>>>...>v>>....>>v..v.v>..>vv.v...>.>>..v.>>v>.>.......v
.v..v....>....>>>.v..v...>vv.v>.>.>v.>.v>vvv>...v...vv>>.>v>.>..>..>v.v.>v>.>.>v.>v......>vv.>v>v.>...>>..>vv.v.>....vv>.>>....v>.>..>>>>..
.>.>vv.v>.>>>vv.v>.>..>..v.>.>>v>v..vvv...>>>>.>>vvv.vv.v.>.v.v>.>>.v..vv.>v.>.>......>..>v.>..v...>>.vv>v..v>v....>v>..>..v>v.v>....v>..v.
..>v>>v..>>....>v..v.>>.>.v.vv.>>.v..>...vv..>..>v..>....v.>..>..v.v..>v..v..v...>.v..>>v...>.v>.vv..v.vvvv>.>>>..>.>..>>>.>..>>v>....>.v.>
...v>vv>...>>...v.>>>...>vv>v>v..>....>v..>.>..v..v>...>.>v.vv.....v..>v.v>....>.......v>...v.v......vv.>..v.>>>v>v.v.vvvvv.>....vv>..>....
>..v.>>>.v>>v..v..v....v>v..vv>...v.vv.v>vv...>..>.>v>..v>>.>>v>v..>..>.>....v>.>v>>vv.v>>>.....>>....>.v.v>.>.>>>....v.>.v>v>.>>>..v..>.>>
>v>v.>...>v.......vv>............>......>>..>v>>.>v.v.vv..v>..>.v.v>v>..v...>>>.>vv>vvv..v.....>>.>v..>.v.>>v>>>v.v...>...v.>v..v..>..v>.v>
.v...>..vvv...v.vvv...vv>>..>v..v.v...v.>..v....v...v.v...>v....>..>.vvv.vv..v.>v.>.>..>..>>vvvv...v..v.>v..>.v.v.v..>v.....vv..>vv>.>...v.
>.>..>..v...v.>...v>>..v.....>v....v>v.v>.vvvv....v>>.v>...v.>....v>v.v>>>.>...v>vv>..>.....>.v>..vv.v>>>v.>>>.>v.vv...>>......v>..>.vvv>.>
.>......>v.vv.v.vv.>>>>v>.>v>.v...vv...v>.>v..>.v.v......>.v...v..v>>.>vv.vv.v..v.vvv>>v>..vv.v>..>..>v..v>>>>.>...>..v..>>>..vv.vvvv..v>v.
v>.v..>.......>vv.vvv....v>>v>>v..vv>..v.>v..>..v>v..>.>v....>v....vv..>.....>...vv.>...vv..>>v...>..v.....v.>..>.>.>>v.v.....>.>.>vv..vv.v
..v..v.v..>v>....v>>...v...>...v>.v..>vv>.vv.vv....vv...vv.>.v>>>..v>.v.>>vv.v.v>.>>>>>v..v>v>>.>.v..v.v.>v.>v>..v>>.vv>>..>>.v..>v>v.v.v.>
.v..>v.>>v..>.v>vvv.v>>..v>v.>..>..>v>.vv.v.>...>.v>>>..v....>.>.>>.v.vv>>>>.v.......>>.>>v>......vv.>>.>...v.v>...v..>..v.>v.vv...v..>>v..
>..>..v..v>>>v>..v>>>.>......v>....v.v.v.>>>.v..>vv..>.......>.v.>.....v.>vv>v>>...vv>v..>>.v...>.>v>>>v>vv.vv.>v.>...v>.>.>.vv...>>..v....
..>..>..v.>>v.v.>..>v>v.>.vv>...>....v>v.v...v.vv.v.>>>v>v>.v.v.....>>..>..v>...>>...vv......>>>...v>>>v>..vv>>>vv.>..>>vv>.......v...>v...
.>.v.......v>v.>v....vv>v>.>.v>>..>v>.>>vv...v.....>.v>>.>v>.>.>>>>vv>..v.v.>>>.>.>>.>.v.v...vv.v.v..>.>>v...>.v>>>...v>vvv.v.......v.>.v..
v>vv.>>>v.>.>...v>>>...>.v.>..v....>...>..v.v.v.>v.v..vv..>..>>>v>.v.>.>..v>.>.v.v..v.>v....v>>.....>>..>vv....>.>>>>.vv>..>.v>>v>v>..v..vv
>>v..>...v>>....>v......vv>..>v>v...>...v.v>>v>...vvv.>>..v.....v>>v>.v.v>v...>.................>.>...>.>...vv..>..v.>..>..v.>>vv..>.>.>>>v
v>.v>>v>>..v.vv.>v...>>..>.vv>..v...>>>...v.v.vvv.>>>.>>..>v.v.>v..>..v.vvv..v.vv....v>.>>vv.>..v..v>v...>.>..>......vv>.>..>v.>>>.v>>....>
>.>>..v..v.......>........>..v.>.vv.vvv.....>.....>..v..v.>>..>>.>>..>>.v..>>>..v.....>vv>.>vv>...>.>.v..v.v.v.>>v.v..v>>>v>v>vvv.v.v..>v>>
...v>v>>...vv....>...v..>.v.>.....>...>....>..v.>.vvv>.v>v>...>vv>...v..v>>.....>.vv..>>v.....v>>>.v>v.....v.v..v>vvv....v.v>>vv.v.....v..>
>v>>.>.>.>vv...>.>v.>v.>.....v..>vv..v.>v.>.>vv>..vv..v.>.>vvv.....>v.>vv..v..>...>.>..>>.>..v..v.>...v>.v.v.v..>v.vv>.>...>v>v.v>vvv>>>..>
v....v...vv.v>....>v.>v..v..vvv..vv.v..>..vv>>.>...v.>vv...v>.......v.......v>>>>>vv..v.>v.v....>v>v.vvv.>.v.>.vv.v....v..v.>vv....>>>v.v..
.vvv.vv>vvv>.v>..v.v.>.v..>v..>v..v>>vvv..vv.>..>....v>v.v.>..>..v...v..>.>...>v...v......>v.v.>vv>..vv>>>v.>.v...v..>vvvvv..v..vv.>..v.v.v
v.>..>v.v.>.v>.>v.v.vvv..>v>>.....>>>vv..>.....v.>..>.>.>.>v..>..v..>>.v....>...>>....>.v.v.>>v>>v.v......v>..vv.v.v>>.>v.v>.>.>.......>...
>.v.......v..>.>>.....vv>v..v.>..v.v...vv>.....v.>v.vv..v.....v>vv...v.>>.v.v...>...>>vvv>.>v.....>....>....>.>v..vv.>v...vv.v.v..vv.>.v.v.
v.v....v>vvv>vv.vv...v..vvvvv.v>v..>..>..v>>...v>>.>v.>>.>>>>>..v...>...>.>..>vvv..>>...>...>..vv>>>..v>>.>..v>.....v..v>vvvvv.>..v.v>.vv.>
>>.vv.vv..>>..>v..v.v>.v..>>.>>v.>>v.v.>>.v>.>>v>..>vvv.>>v.>...>.>>>v.>.....vv>.....>.>..>...>.>....>..v.v..>.v.v.>v.vv.v.>>v..>.vvvv>v>.>
v..>vv...vvv>.v..v.>vv>..>.v.>v.v>....>>...v.>v.>>>.>.v>>.>..>.....>..>>.v>vvvv.vv>v..........>.>>>vv.>.v..v.v..v..vv>v>v..v.v.....>..v.>v.
v>v.v>v>vv..>>vvv..v>...>v.>.v.>>...>v....>.v>.>v>...>>>>..>v.>>..vv.>....>>>..>...>>.v.>>>..>v...>vv........>....v.v..v..>v>>>>>..v..>>...
>>.v.>.>>vvv>>.v>v.>v>...v.v...>...>>v......>.>.>>>.>v>....v...>v..>>..v>...>.v>>.v..v>>v.v.>>.>>v.>..vvv>..v....>>.v>..>v.>...v...vv..v...
vv..>...>v>>v..>..v>..>.v.vv..>...>>.v.vvv>v>.vv..>.v.>>.>.vv.>...v....v.>>v.v.vvvv..>.v.......>.v........>>.vv.v.v..>..vv.>..v...>..vv.>v.
v.v.vv..v>..v.vv..>>v>v.>v..v>...>vv>.>>v.>.>>.v...v>...>.vv.>...vv...v.......>>..>.v.v..>>.....>.......>...v...v>.v..>vv..v>.>>vvv.>..vv.v
...vv.vv>.v.>.v.vv>.>.....>>>.vv.>>v.v>...vv>.v>.>...>..>vvv>....>v........vv...>...>v>>.v...>.vv.v......vvv>..>..>.>.v>.>.v....v...>>>.v.v
...v>>.v.....v....>v>...vv>>..vv.vv>>vvv>.>>>>....v...vv.>v..>vv.v.>>>vv.v>.....>.>......>v.vv>>.v.v..>.vv>.>v...>...>...v>>.v.vv....>...v>
.>>.vv..>>>>..>vv....v.>v.>..>..>>..>.>v>.v>>.>.v..>..v...>.v......v...v....>>.>.v.....v.v..v..v...v..vv>v..v...>...>>..v.v.>vv..v>vvv.....
vv.>.>.v.v.......>...vv>vvv..v...v.v...>v..>....>.>>>...>v...>v.>>.vv....vv>>.....v..>v.vv..v...v....>.v.>>...v.v.>>>.>v.>.>v....v.vv....>v
>>v..>>..>....v...v.v.>..v>v..>>v.>vv..v>.v..v.v.....v.>>.vv.>.>>.>.>>..v..v..v.>..>>.>...>.v>>>>v.v...v..v..>>....>>>v.>>v.v...v.>v.vvv.vv
v>>v.....v..v.v...v>.v...v>v.....>>..>.v.v..vv.>.>v..>v>>.>.v...v.v.>vv...v.>.>>.vv...>v>.>>>>.>>vv.....>vv>...v..>v>..>....v........>...vv
....v..>>...>v.>>..>.v..>v...>.vvv.>......v....v.......>vv>v....v>>>>>..>v>...>v>.>.>vvv.v.>>>..>....v>..v>.vv....v>>>>>.>>.>.>.v>>.>..vvv>
.>v>...v>v>...>...>.v..>v>>.>>..v>.>.vv>..v.>..v..>>.v..vv>.>..>.v.>>.>v>>v.>....v.>vv>.>>.v.>.>.v...>>>vvv..v>>.vv..v...vvv...>...>.>..v..
.>..v.vv..>.>...>...>.>.vv...>.>.....v......v.vv>vv..vv...>.>..>.>>v..>>v...v.vv...v>...>vv..>.v.v>>v.>.vv..>..>vv>..>..>....>..vv>.>...>.v
>.>.>>....>v...v....>v...v.v...v..vv.>......>>.>v>>v..>vvvv....v.>>vvv>v....>vv.v.vv....vv>>.v....>...>>..>>v.>.>v...v.>v>v>.....>>vv.v.>..
v>.v.>..>v.>>..v.v..vv.>.vv>.v..v...>v...>vvv.>....v..>vv>.v>.>.v..v>>..>vv.vv.>..vvvv>...v>..v..>..>..v>>......>v..v.>>.vv.....>.>...v>vvv
>v.v>.v>>>vv....>.>v.>>.vvv.v.>....v>vv.>v.>v..vv>..>...>>...>vv.>vv...v>........>.>v>>>>..>v...v.v>>>vvvv>>.v>v.>...v>..>>.>.>vvv.vv.>vvvv
..>v>vvv>vv..>>.v>v.v..v.>v.v....v...vvv..>.>.vv>.....>>v.>...v.>>.vvv>>.vv>..v..>...v>>>>.v.v.>.>>>......v.>>.v.....v>>.>..>v.v...v.>vvv>.
>v.v>.v>..v>vv.>>.v....v..>...>>.>v...>v..v>.v>v>v..>vvv>v.vv..v....vv.....vv.vv.>>>.vv>....>v..>>.v>.v.>>.>..>.......>v>>>>...v.>..v.vv>v>
vvv.>..v.>v>.......v>>.>.v>.vv.vvvv>.....>v...vv>.>vv>......>.>.>v.v.>..>....>v>v.vv>.v.>..v>v>...v>>vvv.vvv>v.>.>.>..vv.vv..>v>>v>.>.>.>..
v>v.....>vv>>..v>v>......>>>...>v...>v>.v.......vv....>..v>..vv>>v>..v......vv..v.>v>>v..>.v.v..v.>.v.v>...vv...v>...v>v>>>v>>.vv.>>..>.v.v
v.vv.v>v..>.vvv>.>...vv>..v.v..v>vv>>v.v>.v>vvv.>...>..v>..>.>.>.>>...v.v>......>vv>>..v.v>v.........>v..>..v>vvvv>vv..v>..>.>....>>v.>v>v.
>.>>.>.vv...>.vvv>>>>....>vv.>>v>...vv...vv>>>>>..>.v....v>v.>>...>.>.vv.>>.v....v..v>..>>....>v>>>..>....>.v>v...>v>.>v.v>.v..>.......v>vv
.>v..>>v>.vv.....>v..>.>>>v>.>.v..>>....vv.>.v.>v>.>vv>...>...>>..>.vv..>v...>.v.>.....v..>..>.v.>.>>v..v..>v>vvv..v.>vvv.>.>v..v>..>.v.>>.
...v>.>v..>v.>.v>.v>v..v.v>>>>.v.v>v..>v>.v>..v..v.>..>.v..>.......v.v..v.>.>>vv.vvv.v..v.v.v..>v..>vvvv........>vv..vvvvv..v>...v>.>.v.v.>
.v>...v>>v>v>v....v.v>..v>.vv...>...v.v.v..v.>v.v.>vvvv.>>.v..>v..>>v>vv.>vvvv>v>...>...v>>...>vv.v..>....>.>v.v.>>v.vv..>...>v..>v>.>>>>>v
>v>v.v>>v.v..>>..v>..v..vv.....>v.>>...v.v....vvvv..>....>>vv..v>.v>>>v...>.v.v.v..>v..>>....>.v..v..>vv.v......>..v>.v>.v..v>.>.v>...>..>.
>...v.>>>...v>vv.v>.>.v.>>>v>..vvv>>vv..>.>v...>>vv.v..>>vv>....>>...>...vv..>.vv..vvv..v.>..>.v.v..v.>..>v>.>>..>>.>vvv.>..v>>v..>>..v>>>>
>v..>vv>..v...vvv>>.....>.>.>v>..v.vv.v..>>.....>.v.>vv>v.>>v...vv.v>vv..v>..>v>..>>v.....v.v...>....>>>.>>v.>.>..vv.....>>>..vv..>........
>>..>>v.v.v>v....>.>>>v..v...v>..v..>>>.>.>..>...>..v>.vv.......vvvvv.v.v.>vvv>v..>v.>v.v...>v...>v.>v..v>v..v..v.v...>vvvv.>v..vv..vvv....
.v......v.>..>v>>.>>>.>.......vvv>>vv...v....>vv......>.>vv>..vv..>..>...>v....>>>..v.v..vv>..>vv>v>vvvv..v.v..v>..v>.vvv>v..>v....>..v..>>
...>.>..>v..>.v.>.v..v>..v>>.>...vvv>.>>.v.v...>vv.>v.v.>.v..v.v.>..>.>>.>..>v.>>.>vv.v>>.>>..>v>v>.v..>.vvv>v>v.>v..>>.v....>.v>........>>
...>v.>>..>vv>..v>>.v..vv>.v..v...v>.v.v.v..>>v..v..>.>v..>...>..>..>>vv.v>...vvv.v..>v.vv..v.>>>.>.>.....v>......>.v.......v...v>.v>>>..>.
>.>..>.v.>.>v>>>.>.v.>......v..>...>.>vv...>v>..v.v>>vv.>>....vv>..>>.>>..>.v..>>..>v.v>>v>.v.vv>>.>vvvv>v>..v.v>.v...v>...>vvv.v.v>v>v..v.
v.v......v>.>>v.v........v.v.v>.>..>.>..v.>v>.>..v.v..v...>v.....>..>>>>v>>.>...>>.>v.>>.>.vv...v..>.vv>......>vv.....vvv..v>vv..>.>..v>.>.
.>>>.v.vv>......v>.>>.>.vv>...>.vv.>>>>vv.v..>v..vv>v.v..>.v>.v...v.>>.v>>vvv.v......>.v>>....>..v...v..vvv..>v.v>>..>v.>.......>v...>..>..
...>>>.>>.>.v.v>.>.>vv...>...v.>...>v.>...>v>.v.v..>..v.>.>.v..v.vvvvv..v...v.>......v.v>...>v>.>.v>.vv>...>...>.>.>>v...vv.>>.>.v...>>>...
.v..v.v..vvvv>v>....>..v.v..v...v>..>>..v.v>.>..>.....>.v.v>....>..v.v..>..>vv>>.v.v>..vv>.>>v..v.>..>..v...>>>..v>.v>..>.v>.>..>..vvvv.v..
.>v.vv>.>..>.v.v>.>>...>v.v...v.>.>.....>>..v.v.>>>.>..v..>.v>.vvv.v...v>>.v>.>.v.>.>v>v...>...>............v.>v...>....v...>..v...>..v...v
vv>>..>.>..v.vv.>.v.v....>.>vvv.v>>...v>v>v.>>v.vv>...>>..>.>.v>>....v.>...>.v...vv>v>vv.>..v>v.>....>vvv>....v>..vvv..>.>..vv.>>.v.v..v..>
..>....>.vv.>vv.>.v..v.v.v>.v..v.....>.>v.v..>>v>v.>v>>..>v.v.....>>>.....v>>>...>>.v..>v....>..v....>v.v..>>v..v.>>>v.v>.>>..>..>..>...>v.
v>v.v>vvv...v..>>>...v.v>.v>.>..v.>>..>>vvv...v.>v.>v.v>.v...v.vvv.vvv.>...>.....>..vv..>>.>..v..vvv.v.>.......vv.>>...>.>.v..v..>v..v.v>v.
.>.>v>.v.v>.>v>v.>.vvvv.>..vv...v...v.v>.>v.>.v..v>vv>..v.>.>>>v....v..>..>>..>v..>.......vv>>vv.....vv.>>.v.>>v>..>v.vv.....>.>.....>.v.v.
>.v>v....v.v>..>.>v>.v...>>>v>.v..vv..>vvv>..>v..v>vv>>v.>>v>vv.....>.>v.v>vv.>>.vv>v>>..>.v>v>v.>.vv.vvv>>.>..v>>.vvv.v>>.>.vvv.v>vv.v>.>>
>>.v....v..>vvv>>...vvv>>.>..v>..vvv.....v>.v>.v.>...>.............>..v.v....v.v>.vv.>..>v..v....>v.>>vv...v...>v.v..>>....v..v.vv>v..v...>
>v.>v..v.>.v.v.>..>>.>v>.v.v..v.vv.vv.vvvv.>>vv...>v.....v>...>.>>v.>>...>vvvv>.vv>.v....v>v>>>v...>.vvv>..v...v..v>.>>.>>>........>>.v.vv.
.v.v.........v.>>v.>vv.v.v.>vv>>v>>>.vv>v>>v.>>>>v....>>.v..>.v>v>>...v.>.v..>.v>>>..>>v..v>.v.vvv.>v.>..>..>...vv.>>>...vv....vv....v....v
>>>vv.v.>.v>.>vv..>.v.....>...>..>.vv>>v...>.......v...>.>.>>v.vv>vv..v.>vv....v....>.>.v.>v>v..>>v....v.>>...v>>>>v....v>.....vv...v>vv..v
>v.v....>>.>v>.>>v.>..>>>.......v.v.v..>vvvv.>v.>.v.v.v.v..v>.v.>..v>..v>.>>.....v>.>>..>.>>>...>v.>>v..v....>>.>.vv.vvv.>v..>>>....>.v...v
>.>.v.....>..v>vv>>>..>..v.>vv>vvvv...vv....>.>.v>>.>>.>.v..v..........vvvvv.v.v.v..>vvvv.....v.>vvv...>v..>>v>v....>.>..>>..v>>v.>v.vvv.v.
.....v>>>...v..v..>...v.>v.>v.v..>>>..>>v>.v.v>vv>.>..>vv....v>...v>vv>>.....>.v...v..>vv.>v..>.v.vvv.>.v.vv..v...>..vv..>v>>>..>>...v...vv
>v>v.>.v.>vv..v...>.>.>.....v>vv..>>.v...>.v...v..>..v.v..>......>v>>.....>>>v..v.>>v>>v.v>v>.>v.vv.>..v...vvv..>.>>.>....v>..vv.v..>..vv.v
.v>.>>....>>>.vvv.>.vv..>vv..>.v.v.v>.vv..vvv.>..>.vv..vv...v..v.v..>v..>..>v......>>.>v.v.v.v.vv>.......>.>>...v.vv>.>>..v.v>.v.>>.vv.v.>.
v.v>>>.>..>v>v.>>>.v.v>v.v.v..vvv.v>v.>.>>>.>v>v.v>.>vv...v>.>v.v.vv...>.v.v>>>vvvv>.v..>..>v......v..>.>v>.v..>...v>v>.>...v.v>.vv.>v>.v>v
..>>.v>>.v.v.>vv.v...v.....v..>...v..v>.>>>vv.v>>v.>vv.>>>.v...>.>>....>...v....>vv..>v>.vv.>...v..>v..>.>.>.v.vv..v.>...v.v>..vv>.>>......
.v...>>>vv>>v.....v>...>>.>..>...>v>>>v.v.>.>vv>vvv.v>.>..v..v>v..v>...>>>>vvvv..vv>>..v.vv.>vvv....>..v..v.>.v.vv>v>.v>>....>v.v..>>vv>>vv
..v.v>..vv.v...>.>v...v>>v>v.>vv.v..v>>>v>.>.v.vv.>.>v..>>...vv.v..v..v.>>..>>>>>>..>>.v>..v>>>v.v>v>>.vv.>..>.v..v..>..>v.....>v>.vv>>>>v>
...v.....vv..v....v.>...>...v..v...>.>>v..>.vv...vv.>>...v...>>v....v....v>>...>....>v.v..>>.....v....>>>vv>>...vv..>>v..>>...>>vv..>.v.v>>
.>..>...>..v.>..v>>>...v..>>.....>..v.vv.v>>.....>...v>..vv>>>v...>.v>v>v>v.>.>.vv..>>>>..vv...>..>>vv>...>>...v>.>>>v>>....v>..>.>>.>v.>.>
