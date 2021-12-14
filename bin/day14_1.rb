#!/usr/bin/env ruby -Ilib

require 'json'

class String
  def all_indexes_of(substr)
    idxs = []
    loop do
      next_idx = index(substr, idxs.empty? ? 0 : idxs.last+1)
      break unless next_idx
      idxs << next_idx
    end
    idxs
  end
end

RULES = DATA.lines.map { _1.strip.split(' -> ') }.to_h

output = []
# polymer = "OKSBBKHFBPVNOBKHBPCO"
polymer = "NNCB"
# puts polymer
10.times do |idx|
  puts "Iteration #{idx}"
  output << polymer.dup
  puts polymer.to_s

  insertions = {}
  RULES.each do |(pattern, sub)|
    polymer.all_indexes_of(pattern).each do |match_idx|
      insertions[match_idx+1] = sub
    end
  end

  insertions.to_a.sort_by(&:first).tap(&:reverse!).each do |(insert_idx, ch)|
    polymer.insert(insert_idx, ch)
  end
end

File.write('day14.json', JSON.pretty_generate(output))

pp polymer.chars.tally.sort_by(&:last)
least_common, most_common = polymer.chars.tally.values.minmax
puts most_common - least_common

# __END__
# CB -> P
# VH -> S
# CF -> P
# OV -> B
# CH -> N
# PB -> F
# KF -> O
# BC -> K
# FB -> F
# SN -> F
# FV -> B
# PN -> K
# SF -> V
# FN -> F
# SS -> K
# VP -> F
# VB -> B
# OS -> N
# HP -> O
# NF -> S
# SK -> H
# OO -> S
# PF -> C
# CC -> P
# BP -> F
# OB -> C
# CS -> N
# BV -> F
# VV -> B
# HO -> F
# KN -> P
# VC -> K
# KK -> N
# BO -> V
# NH -> O
# HC -> S
# SB -> F
# NN -> V
# OF -> V
# FK -> S
# OP -> S
# NS -> C
# HV -> O
# PC -> C
# FO -> H
# OH -> F
# BF -> S
# SO -> O
# HB -> P
# NK -> H
# NV -> C
# NB -> B
# FF -> B
# BH -> C
# SV -> B
# BK -> K
# NO -> C
# VN -> P
# FC -> B
# PH -> V
# HH -> C
# VO -> O
# SP -> P
# VK -> N
# CP -> H
# SC -> C
# KV -> H
# CO -> C
# OK -> V
# ON -> C
# KS -> S
# NP -> O
# CK -> C
# BS -> F
# VS -> B
# KH -> O
# KC -> C
# KB -> N
# OC -> F
# PP -> S
# HK -> H
# BN -> S
# KO -> K
# NC -> B
# PK -> K
# CV -> H
# PO -> O
# BB -> C
# HS -> F
# SH -> K
# CN -> S
# HN -> S
# KP -> O
# FP -> H
# HF -> F
# PS -> B
# FH -> K
# PV -> O
# FS -> N
# VF -> V

__END__
CH -> B
HH -> N
CB -> H
NH -> C
HB -> C
HC -> B
HN -> C
NN -> C
BH -> H
NC -> B
NB -> B
BN -> B
BB -> N
BC -> B
CC -> N
CN -> C
