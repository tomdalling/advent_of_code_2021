#!/usr/bin/env ruby -Ilib

require 'json'

def pairs_from(str)
  chars = str.chars
  chars.zip(chars.drop(1))[0..-2].map(&:join).tally.sort_by(&:first).to_h
end

# STARTING_POLYMER = "NNCB"
STARTING_POLYMER = "OKSBBKHFBPVNOBKHBPCO"

$inserted = STARTING_POLYMER.chars.tally

def diff_for(pairs, pattern, sub)
  count = pairs.fetch(pattern, 0)
  left = pattern[0] + sub
  right = sub + pattern[1]

  $inserted[sub] ||= 0
  $inserted[sub] += count

  {pattern => 0, left => 0, right => 0}.tap do |result|
    result[pattern] -= count
    result[left] += count
    result[right] += count

    # pp [pattern, sub, count, result]
  end
end

def top_and_bot
  ranked_chars = $inserted.sort_by(&:last)
  most_common = ranked_chars[-1]
  least_common = ranked_chars[0]

  pp [most_common, least_common]

  puts most_common.last - least_common.last
end

RULES = DATA.lines.map { _1.strip.split(' -> ') }.to_h

EXPECTED = File.read('day14.json').then { JSON.parse(_1) }.map { pairs_from(_1) }

pairs = pairs_from(STARTING_POLYMER)

40.times do |idx|
  puts "Iteration #{idx}"
  top_and_bot
  # pp pairs
  # pp EXPECTED[idx]
  # pp pairs == EXPECTED[idx]

  diffs = RULES.map do |(pattern, sub)|
    diff_for(pairs, pattern, sub)
  end

  pairs = begin
    ([pairs] + diffs).reduce({}) do |result, diff|
      result.merge(diff) do |_key, v1, v2|
        v1 + v2
      end
    end.reject { |k,v| v.zero? }.sort_by(&:first).to_h
  end
end

puts "-----"
top_and_bot

# __END__
# CH -> B
# HH -> N
# CB -> H
# NH -> C
# HB -> C
# HC -> B
# HN -> C
# NN -> C
# BH -> H
# NC -> B
# NB -> B
# BN -> B
# BB -> N
# BC -> B
# CC -> N
# CN -> C

__END__
CB -> P
VH -> S
CF -> P
OV -> B
CH -> N
PB -> F
KF -> O
BC -> K
FB -> F
SN -> F
FV -> B
PN -> K
SF -> V
FN -> F
SS -> K
VP -> F
VB -> B
OS -> N
HP -> O
NF -> S
SK -> H
OO -> S
PF -> C
CC -> P
BP -> F
OB -> C
CS -> N
BV -> F
VV -> B
HO -> F
KN -> P
VC -> K
KK -> N
BO -> V
NH -> O
HC -> S
SB -> F
NN -> V
OF -> V
FK -> S
OP -> S
NS -> C
HV -> O
PC -> C
FO -> H
OH -> F
BF -> S
SO -> O
HB -> P
NK -> H
NV -> C
NB -> B
FF -> B
BH -> C
SV -> B
BK -> K
NO -> C
VN -> P
FC -> B
PH -> V
HH -> C
VO -> O
SP -> P
VK -> N
CP -> H
SC -> C
KV -> H
CO -> C
OK -> V
ON -> C
KS -> S
NP -> O
CK -> C
BS -> F
VS -> B
KH -> O
KC -> C
KB -> N
OC -> F
PP -> S
HK -> H
BN -> S
KO -> K
NC -> B
PK -> K
CV -> H
PO -> O
BB -> C
HS -> F
SH -> K
CN -> S
HN -> S
KP -> O
FP -> H
HF -> F
PS -> B
FH -> K
PV -> O
FS -> N
VF -> V
