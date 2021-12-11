#!/usr/bin/env ruby -Ilib

require 'grid'

class Octo
  attr_accessor :energy, :highlighted

  def initialize(energy)
    @energy = energy
    @highlighted = false
  end

  def should_flash?
    @energy > 9 && !highlighted
  end

  def highlighted?
    highlighted
  end
end

class OctoGrid < Grid
  def step!
    each_cell do |octo, x, y|
      octo.highlighted = false
      octo.energy += 1
    end

    total_flashes = 0
    loop do
      flash_count = propagate_flashes
      total_flashes += flash_count
      break if flash_count <= 0
    end

    each_cell do |octo, x, y|
      octo.energy = 0 if octo.highlighted?
    end

    total_flashes
  end

  private

    def propagate_flashes
      flash_count = 0

      each_cell do |octo, x, y|
        if octo.energy > 9 && !octo.highlighted?
          octo.highlighted = true
          flash_count += 1
          each_neighbour_of(x, y) do |neighbour|
            neighbour.energy += 1
          end
        end
      end

      flash_count
    end
end

grid = OctoGrid.from_rows(
  DATA.lines.map do |line|
    line.strip.chars.map do |digit|
      Octo.new(digit.to_i)
    end
  end
)

step = 0
loop do
  step += 1
  grid.step!
  break if grid.cells.all?(&:highlighted?)
end

puts step

__END__
1564524226
1384554685
7582264835
8812672272
1161463137
7831762344
2855527748
6141737874
8611458313
8215372443
