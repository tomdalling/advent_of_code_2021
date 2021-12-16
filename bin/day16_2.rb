#!/usr/bin/env ruby -Ilib

require 'byebug'

$version_total = 0

class BinaryStream
  attr_reader :bit_offset

  def initialize(bytes)
    @bits = bytes.unpack("B*").first
    @bit_offset = 0
  end

  def read_int(n)
    read_bits(n).to_i(2)
  end

  def read_bits(n)
    raise "end of stream" unless @bits.length >= n

    bits = @bits[0...n]
    @bits[0...n] = ''
    @bit_offset += n
    bits
  end

  def read_bool?
    read_bits(1) == "1"
  end

  def eos?
    @bits.length < 8
  end

  def skip_until_byte_aligned
    read_bits(@bits.length % 8)
  end
end

def parse_packet(stream)

  version = stream.read_int(3)
  type = stream.read_int(3)

  value =
    if type == 4
      parse_literal_value(stream)
    else
      parse_subpackets(stream)
    end

  $version_total += version

  {
    version: version,
    type: type,
    value: value
  }
end

def parse_literal_value(stream)
  chunks = []
  is_more = true
  while is_more
    is_more = stream.read_bool?
    chunks << stream.read_bits(4)
  end
  chunks.join.to_i(2)
end

def parse_subpackets(stream)
  if stream.read_bool?
    parse_subpackets_by_packet_count(stream)
  else
    parse_subpackets_by_bit_count(stream)
  end
end

def parse_subpackets_by_packet_count(stream)
  packet_count = stream.read_int(11)
  Array.new(packet_count) { parse_packet(stream) }
end

def parse_subpackets_by_bit_count(stream)
  bit_count = stream.read_int(15)
  stop_at_offset = stream.bit_offset + bit_count

  [].tap do |subpackets|
    while stream.bit_offset != stop_at_offset
      subpackets << parse_packet(stream)
    end
  end
end

def eval_packet(packet)
  if packet.fetch(:type) == 4
    packet.fetch(:value)
  else
    eval_operator_packet(packet)
  end
end

def eval_operator_packet(packet)
  subpackets = packet.fetch(:value).map { eval_packet(_1) }

  case packet.fetch(:type)
  when 0 # sum
    subpackets.sum
  when 1 # product
    subpackets.reduce(&:*)
  when 2 # min
    subpackets.min
  when 3 # max
    subpackets.max
  when 5 # greater than
    raise "not right" unless subpackets.count == 2
    subpackets[0] > subpackets[1] ? 1 : 0
  when 6 # less than
    raise "not right" unless subpackets.count == 2
    subpackets[0] < subpackets[1] ? 1 : 0
  when 7 # equal
    raise "not right" unless subpackets.count == 2
    subpackets[0] == subpackets[1] ? 1 : 0
  else
    raise NotImplementedError, packet.slice(:type).inspect
  end
end

INPUT = [DATA.read.strip].pack('H*')
stream = BinaryStream.new(INPUT)
packet = parse_packet(stream)
raise "too many roots" unless stream.eos?


puts eval_packet(packet)

__END__
220D700071F39F9C6BC92D4A6713C737B3E98783004AC0169B4B99F93CFC31AC4D8A4BB89E9D654D216B80131DC0050B20043E27C1F83240086C468A311CC0188DB0BA12B00719221D3F7AF776DC5DE635094A7D2370082795A52911791ECB7EDA9CFD634BDED14030047C01498EE203931BF7256189A593005E116802D34673999A3A805126EB2B5BEEBB823CB561E9F2165492CE00E6918C011926CA005465B0BB2D85D700B675DA72DD7E9DBE377D62B27698F0D4BAD100735276B4B93C0FF002FF359F3BCFF0DC802ACC002CE3546B92FCB7590C380210523E180233FD21D0040001098ED076108002110960D45F988EB14D9D9802F232A32E802F2FDBEBA7D3B3B7FB06320132B0037700043224C5D8F2000844558C704A6FEAA800D2CFE27B921CA872003A90C6214D62DA8AA9009CF600B8803B10E144741006A1C47F85D29DCF7C9C40132680213037284B3D488640A1008A314BC3D86D9AB6492637D331003E79300012F9BDE8560F1009B32B09EC7FC0151006A0EC6082A0008744287511CC0269810987789132AC600BD802C00087C1D88D05C001088BF1BE284D298005FB1366B353798689D8A84D5194C017D005647181A931895D588E7736C6A5008200F0B802909F97B35897CFCBD9AC4A26DD880259A0037E49861F4E4349A6005CFAD180333E95281338A930EA400824981CC8A2804523AA6F5B3691CF5425B05B3D9AF8DD400F9EDA1100789800D2CBD30E32F4C3ACF52F9FF64326009D802733197392438BF22C52D5AD2D8524034E800C8B202F604008602A6CC00940256C008A9601FF8400D100240062F50038400970034003CE600C70C00F600760C00B98C563FB37CE4BD1BFA769839802F400F8C9CA79429B96E0A93FAE4A5F32201428401A8F508A1B0002131723B43400043618C2089E40143CBA748B3CE01C893C8904F4E1B2D300527AB63DA0091253929E42A53929E420
