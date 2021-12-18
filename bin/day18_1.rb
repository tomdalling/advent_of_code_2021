#!/usr/bin/env ruby -Ilib

require 'byebug'

class Pair
  attr_accessor :left, :right, :depth, :parent, :parent_side

  def self.coerce(obj, depth: 0, parent: nil, parent_side: nil)
    case obj
    when Integer
      obj
    when Array
      raise "bad pair" if obj.size != 2
      new.tap do |pair|
        pair.parent = parent
        pair.parent_side = parent_side
        pair.depth = depth
        pair.left = coerce(obj.first, depth: depth+1, parent: pair, parent_side: :left)
        pair.right = coerce(obj.last, depth: depth+1, parent: pair, parent_side: :right)
      end
    else
      raise NotImplementedError
    end
  end

  def self.new_root(left, right)
    raise ArgumentError unless left.parent.nil?
    raise ArgumentError unless right.parent.nil?

    new.tap do |root|
      root.depth = -1 # will be incremented with all other pairs
      root.left = left
      root.right = right

      left.parent = root
      left.parent_side = :left

      right.parent = root
      right.parent_side = :right

      root.traverse(:inorder_left) { _1.depth += 1 }
    end
  end

  def [](side)
    public_send(side)
  end

  def []=(side, value)
    public_send("#{side}=", value)
  end

  def to_a
    l = left.is_a?(Pair) ? left.to_a : left
    r = right.is_a?(Pair) ? right.to_a : right
    [l, r]
  end

  def dup
    Marshal.load(Marshal.dump(self))
  end

  def int?(direction)
    public_send(direction).is_a?(Integer)
  end

  def left_int?
    int?(:left)
  end

  def left_pair?
    not left_int?
  end

  def right_int?
    int?(:right)
  end

  def right_pair?
    not right_int?
  end

  def traverse(order, &visitor)
    case order
    when :inorder_left
      left.traverse(order, &visitor) if left_pair?
      visitor.(self)
      right.traverse(order, &visitor) if right_pair?
    when :inorder_right
      right.traverse(order, &visitor) if right_pair?
      visitor.(self)
      left.traverse(order, &visitor) if left_pair?
    when :preorder_left
      visitor.(self)
      left.traverse(order, &visitor) if left_pair?
      right.traverse(order, &visitor) if right_pair?
    else
      raise NotImplementedError, order.to_s
    end
    nil
  end

  def ==(other)
    to_a == other.to_a
  end

  def inspect
    "#<Pair #{to_a.inspect.gsub(', ', ',')}>"
  end

  def explode!
    raise "can't explode this: #{inspect}" unless left_int? && right_int?

    int_search(:left) do |n, side|
      n[side] += left
    end
    int_search(:right) do |n, side|
      n[side] += right
    end
    parent.public_send("#{parent_side}=", 0)

    nil
  end

  def int_search(direction)
    # search up the tree
    root = nil
    root_side = nil
    prev_n = nil
    n = self
    loop do
      if n.parent.nil?
        root = n
        root_side = prev_n.parent_side
      end
      prev_n = n
      n = n.parent
      break if n.nil?
      if n.int?(direction)
        yield n, direction
        return
      end
    end

    return if direction == root_side # already checked down the appropriate side

    # search back down the other side
    other_direction = (direction == :left ? :right : :left)
    order = "inorder_#{other_direction}".to_sym
    root[direction].traverse(order) do |n|
      if n.int?(other_direction)
        yield n, other_direction
        return
      end
    end

    nil # not found
  end

  # To split a regular number, replace it with a pair; the left element of the
  # pair should be the regular number divided by two and rounded down, while the
  # right element of the pair should be the regular number divided by two and
  # rounded up. For example, 10 becomes [5,5], 11 becomes [5,6], 12 becomes
  # [6,6], and so on.
  def split!(side)
    raise ArgumentError, "bad split" unless int?(side)
    i = self[side]
    self[side] = Pair.new.tap do |child|
      child.depth = depth + 1
      child.parent = self
      child.parent_side = side
      child.left = i/2
      child.right = i - child.left
    end
    nil
  end
end

def assert(condition)
  raise "Assertion failed: #{condition}" unless eval(condition)
end

# To explode a pair, the pair's left value is added to the first regular number to
# the left of the exploding pair (if any), and the pair's right value is added to
# the first regular number to the right of the exploding pair (if any). Exploding
# pairs will always consist of two regular numbers. Then, the entire exploding
# pair is replaced with the regular number 0.
#
# Here are some examples of a single explode action:
#
#   [[[[[9,8],1],2],3],4] becomes [[[[0,9],2],3],4] (the 9 has no regular number to its left, so it is not added to any regular number).
#   [7,[6,[5,[4,[3,2]]]]] becomes [7,[6,[5,[7,0]]]] (the 2 has no regular number to its right, and so it is not added to any regular number).
#   [[6,[5,[4,[3,2]]]],1] becomes [[6,[5,[7,0]]],3].
#   [[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]] becomes [[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]] (the pair [3,2] is unaffected because the pair [7,3] is further to the left; [3,2] would explode on the next action).
#   [[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]] becomes [[3,[2,[8,0]]],[9,[5,[7,0]]]].
def explode!(n)
  n.traverse(:preorder_left) do |p|
    if p.depth == 4
      puts "Explode #{p.inspect}"
      p.explode!
      return true
    end
  end

  false
end

def explode(n)
  n.dup.tap { explode!(_1) }
end

assert "explode(Pair.coerce([[[[[9,8],1],2],3],4])) == Pair.coerce([[[[0,9],2],3],4])"
assert "explode(Pair.coerce([7,[6,[5,[4,[3,2]]]]])) == Pair.coerce([7,[6,[5,[7,0]]]])"
assert "explode(Pair.coerce([[6,[5,[4,[3,2]]]],1])) == Pair.coerce([[6,[5,[7,0]]],3])"
assert "explode(Pair.coerce([[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]])) == Pair.coerce([[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]])"
assert "explode(Pair.coerce([[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]])) == Pair.coerce([[3,[2,[8,0]]],[9,[5,[7,0]]]])"

def split!(n)
  n.traverse(:inorder_left) do |pair|
    if pair.left_int? && pair.left >= 10
      puts "Split left #{pair.inspect}"
      pair.split!(:left)
      return true
    elsif pair.right_int? && pair.right >= 10
      puts "Split left #{pair.inspect}"
      pair.split!(:right)
      return true
    end
  end

  false
end

# To reduce a snailfish number, you must repeatedly do the first action in this list that applies to the snailfish number:
#
# - If any pair is nested inside four pairs, the leftmost such pair explodes.
# - If any regular number is 10 or greater, the leftmost such regular number splits.
#
# Once no action in the above list applies, the snailfish number is reduced.
def reduce!(n)
  loop do
    pp n
    next if explode!(n)
    next if split!(n)
    pp n
    return
  end
end

def reduce(n)
  n.dup.tap { reduce!(_1) }
end

def reduced?(n)
  n == reduce(n)
end

def add(n1, n2)
  p = Pair.coerce([n1.to_a, n2.to_a])
  reduce!(p)
  p
end

pp add(
  Pair.coerce([[[0,[4,5]],[0,0]],[[[4,5],[2,6]],[9,5]]]),
  Pair.coerce([7,[[[3,7],[4,3]],[[6,3],[8,8]]]]),
)

assert <<~RUBY
  add(
    Pair.coerce([[[0,[4,5]],[0,0]],[[[4,5],[2,6]],[9,5]]]),
    Pair.coerce([7,[[[3,7],[4,3]],[[6,3],[8,8]]]]),
  ) == Pair.coerce([[[[4,0],[5,4]],[[7,7],[6,0]]],[[8,[7,7]],[[7,9],[5,0]]]])
RUBY
abort

DATA.lines
  .map { |line| Pair.coerce(eval(line)) } # dont look
  .reduce { add(_1, _2) }
  .tap { pp _1 }

__END__
[[[0,[4,5]],[0,0]],[[[4,5],[2,6]],[9,5]]]
[7,[[[3,7],[4,3]],[[6,3],[8,8]]]]
[[2,[[0,8],[3,4]]],[[[6,7],1],[7,[1,6]]]]
[[[[2,4],7],[6,[0,5]]],[[[6,8],[2,8]],[[2,1],[4,5]]]]
[7,[5,[[3,8],[1,4]]]]
[[2,[2,2]],[8,[8,1]]]
[2,9]
[1,[[[9,3],9],[[9,0],[0,7]]]]
[[[5,[7,4]],7],1]
[[[[4,2],2],6],[8,7]]
