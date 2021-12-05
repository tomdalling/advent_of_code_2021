require 'vec2'

RSpec.describe Vec2 do
  subject { Vec2[x, y] }
  let(:x) { 5 }
  let(:y) { 7 }

  it "has x and y components" do
    expect(subject).to have_attributes(x: 5, y: 7)
  end

  it "has a magnitude" do
    expect(subject.magnitude).to be_within(0.0000001).of(8.602325267)
  end

  it "defines equality" do
    expect(subject).to eq(Vec2[5, 7])
  end

  it "can be multipled by a scalar" do
    expect(subject * 2).to eq(Vec2[10, 14])
  end

  it "can be negated" do
    expect(-subject).to eq(Vec2[-5, -7])
  end

  it "can add another Vec2" do
    expect(subject + Vec2[1,2]).to eq(Vec2[6,9])
  end

  it "can subtract another Vec2" do
    expect(subject - Vec2[1,2]).to eq(Vec2[4,5])
  end

  it "is immutable" do
    expect(subject).to be_frozen
  end

  it "can be used as a hash key" do
    hash = {}
    10.times do
      hash[Vec2[1,2]] = true
    end

    expect(hash).to eq({Vec2[1,2] => true})
  end
end
