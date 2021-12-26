#!/usr/bin/env ruby -Ilib

require 'byebug'

class ALU
  attr_reader :instructions, :registers, :inputs, :failed_at_digit, :zs

  def initialize(instructions)
    @instructions = instructions
    reset!(input: "13579246899999")
  end

  def reset!(input:)
    @registers = {x: 0, y: 0, z: 0, w: 0}
    @inputs = input.chars.map(&:to_i)
    @input_idx = -1
    @failed_at_digit = nil
    @zs = []
  end

  def run!
    instructions.each do |(instr, *args)|
      send("apply_#{instr}", *args)
    end
    record_z
  end

  def input_valid?
    registers.fetch(:z) == 0
  end

  private

    def record_z
      # pp registers
      @zs << registers.fetch(:z)
    end

    def resolve(reg_or_value)
      case reg_or_value
      when Symbol then registers.fetch(reg_or_value)
      when Integer then reg_or_value
      else raise NotImplementedError
      end
    end

    def apply_inp(reg)
      record_z if @input_idx >= 0
      @input_idx += 1
      registers[reg] = inputs.fetch(@input_idx)
    end

    def apply_add(accum_reg, other_reg)
      registers[accum_reg] += resolve(other_reg)
    end

    def apply_mul(accum_reg, other_reg)
      registers[accum_reg] *= resolve(other_reg)
    end

    def apply_div(accum_reg, other_reg)
      other = resolve(other_reg)
      crash! if other == 0
      registers[accum_reg] /= other
    end

    def apply_mod(accum_reg, other_reg)
      accum = resolve(accum_reg)
      other = resolve(other_reg)
      crash! if accum < 0
      crash! if other <= 0
      registers[accum_reg] = accum % other
    end

    def apply_eql(accum_reg, other_reg)
      registers[accum_reg] = (resolve(accum_reg) == resolve(other_reg) ? 1 : 0)
    end

    def crash!
      raise "ALU crashed"
    end
end


# inp w        inp w
# mul x 0      mul x 0
# add x z      add x z
# mod x 26     mod x 26
# div z 1      div z 1    <---- 1 or 26
# add x 11     add x 11   <----
# eql x w      eql x w
# eql x 0      eql x 0
# mul y 0      mul y 0
# add y 25     add y 25
# mul y x      mul y x
# add y 1      add y 1
# mul z y      mul z y
# mul y 0      mul y 0
# add y w      add y w
# add y 1      add y 11  <-----
# mul y x      mul y x
# add z y      add z y
def doit
  # inp w
  w = next_input
  # mul x 0
  # add x z
  # mod x 26
  # add x 11
  # eql x w
  # eql x 0
  x = (z % 26) + 11 != w
  # mul y 0
  # add y 25
  # mul y x
  # add y 1
  # mul z y
  z *= (x ? 26 : 1)
  # mul y 0
  # add y w
  # add y 1
  # mul y x
  # add z y
  z += (x ? w + 1 : 0)
end

SIMPLIFIED = [
  {div_z: 1, add_x: 11, add_y: 1},   # 9
  {div_z: 1, add_x: 11, add_y: 11},  # 9
  {div_z: 1, add_x: 14, add_y: 1},   # 9
  {div_z: 1, add_x: 11, add_y: 11},  # 9
  {div_z: 26, add_x: -8, add_y: 2},  # ...
  {div_z: 26, add_x: -5, add_y: 9},  # ...
  {div_z: 1, add_x: 11, add_y: 7},   # 9
  {div_z: 26, add_x: -13, add_y: 11},# ...
  {div_z: 1, add_x: 12, add_y: 6},   # 9
  {div_z: 26, add_x: -1, add_y: 15}, # ...
  {div_z: 1, add_x: 14, add_y: 7},   # 9
  {div_z: 26, add_x: -5, add_y: 1},  # ...
  {div_z: 26, add_x: -4, add_y: 8},  # ...
  {div_z: 26, add_x: -8, add_y: 6},  # ...
]

SIMPLIFIED.each_with_index.reverse_each do |params, idx|
  params[:max_z] =
    if idx == SIMPLIFIED.size - 1
      params.fetch(:div_z) - 1
    else
      SIMPLIFIED[idx+1].fetch(:max_z) * params.fetch(:div_z)
    end
end

pp SIMPLIFIED

class ZedTooBig < StandardError; end

def apply_simplified(z:, input:, div_z:, add_x:, add_y:, max_z:)
  if (z % 26) + add_x != input
    (z/div_z)*26 + input + add_y
  else
    z/div_z
  end
end

def smallest_serial(serial_so_far="", z=0)
  step_idx = serial_so_far.length
  if step_idx == SIMPLIFIED.length
    puts serial_so_far
    if valid?(serial_so_far)
      return serial_so_far
    else
      return nil
    end
  end

  1.upto(9).each do |digit|
    next_serial = serial_so_far + digit.to_s
    next_z = apply_simplified(z: z, input: digit, **SIMPLIFIED[step_idx])
    is_last = (step_idx == SIMPLIFIED.length - 1)
    if is_last || next_z <= SIMPLIFIED[step_idx+1].fetch(:max_z)
      found = smallest_serial(next_serial, next_z)
      return found if found
    end
  end

  nil # couldn't find any digit :(
end

def valid?(serial)
  byebug unless serial.length == SIMPLIFIED.size

  inputs = serial.chars.map(&:to_i)
  0 == SIMPLIFIED.reduce(0) do |z, params|
    apply_simplified(z: z, input: inputs.shift, **params)
  end
end

ss = smallest_serial
puts "------"
puts ss
exit

# alu = ALU.new(
#   DATA.lines.map do |line|
#     next if line.strip.empty?
#     line.strip.split.map do |token|
#       Integer(token, exception: false) || token.to_sym
#     end
#   end.compact
# )

# alu.reset!(input: serial)
# alu.run!
# pp alu.zs.size
# pp alu.zs
# pp alu.registers

# SINPUTS = serial.chars.map(&:to_i)
# all_zs = []
# triggers = []
# final_z = SIMPLIFIED.reduce(0) do |z, params|
#   triggers << (z % 26 + params.fetch(:add_x))
#   apply_simplified(z: z, input: SINPUTS.shift, **params).tap do
#     all_zs << _1
#   end
# end
# pp all_zs.each_with_index.to_h { [_2, _1] }
# pp triggers

__END__
inp w
mul x 0
add x z
mod x 26
div z 1
add x 11
eql x w
eql x 0
mul y 0
add y 25
mul y x
add y 1
mul z y
mul y 0
add y w
add y 1
mul y x
add z y

inp w
mul x 0
add x z
mod x 26
div z 1
add x 11
eql x w
eql x 0
mul y 0
add y 25
mul y x
add y 1
mul z y
mul y 0
add y w
add y 11
mul y x
add z y
inp w
mul x 0
add x z
mod x 26
div z 1
add x 14
eql x w
eql x 0
mul y 0
add y 25
mul y x
add y 1
mul z y
mul y 0
add y w
add y 1
mul y x
add z y
inp w
mul x 0
add x z
mod x 26
div z 1
add x 11
eql x w
eql x 0
mul y 0
add y 25
mul y x
add y 1
mul z y
mul y 0
add y w
add y 11
mul y x
add z y
inp w
mul x 0
add x z
mod x 26
div z 26
add x -8
eql x w
eql x 0
mul y 0
add y 25
mul y x
add y 1
mul z y
mul y 0
add y w
add y 2
mul y x
add z y
inp w
mul x 0
add x z
mod x 26
div z 26
add x -5
eql x w
eql x 0
mul y 0
add y 25
mul y x
add y 1
mul z y
mul y 0
add y w
add y 9
mul y x
add z y
inp w
mul x 0
add x z
mod x 26
div z 1
add x 11
eql x w
eql x 0
mul y 0
add y 25
mul y x
add y 1
mul z y
mul y 0
add y w
add y 7
mul y x
add z y
inp w
mul x 0
add x z
mod x 26
div z 26
add x -13
eql x w
eql x 0
mul y 0
add y 25
mul y x
add y 1
mul z y
mul y 0
add y w
add y 11
mul y x
add z y
inp w
mul x 0
add x z
mod x 26
div z 1
add x 12
eql x w
eql x 0
mul y 0
add y 25
mul y x
add y 1
mul z y
mul y 0
add y w
add y 6
mul y x
add z y
inp w
mul x 0
add x z
mod x 26
div z 26
add x -1
eql x w
eql x 0
mul y 0
add y 25
mul y x
add y 1
mul z y
mul y 0
add y w
add y 15
mul y x
add z y
inp w
mul x 0
add x z
mod x 26
div z 1
add x 14
eql x w
eql x 0
mul y 0
add y 25
mul y x
add y 1
mul z y
mul y 0
add y w
add y 7
mul y x
add z y
inp w
mul x 0
add x z
mod x 26
div z 26
add x -5
eql x w
eql x 0
mul y 0
add y 25
mul y x
add y 1
mul z y
mul y 0
add y w
add y 1
mul y x
add z y
inp w
mul x 0
add x z
mod x 26
div z 26
add x -4
eql x w
eql x 0
mul y 0
add y 25
mul y x
add y 1
mul z y
mul y 0
add y w
add y 8
mul y x
add z y

inp w
mul x 0
add x z
mod x 26
div z 26
add x -8
eql x w
eql x 0
mul y 0
add y 25
mul y x
add y 1
mul z y
mul y 0
add y w
add y 6
mul y x
add z y
