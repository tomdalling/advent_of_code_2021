require 'grid'

RSpec.describe Grid do
  subject { described_class[3, 2] }
  before { subject[0,0] = true }

  it "has a fixed number of rows and columns" do
    expect(subject).to have_attributes(
      row_count: 2,
      column_count: 3,
    )
  end

  it "has a cell setter and getter" do
    expect(subject[0, 1]).to eq(nil)
    subject[0, 1] = 66
    expect(subject[0, 1]).to eq(66)
  end

  it "has cells" do
    expect(subject.cells).to eq([true, nil, nil, nil, nil, nil])
  end

  it "has rows" do
    expect(subject.rows).to eq([
      [true, nil, nil],
      [nil,  nil, nil],
    ])
  end

  it "has columns" do
    expect(subject.columns).to eq([
      [true, nil],
      [nil,  nil],
      [nil,  nil],
    ])
  end

  it "can be created from rows of cells" do
    grid = described_class.from_rows([
      [1,2,3],
      [4,5,6],
      [7,8,9],
    ])

    expect(grid).to have_attributes(
      row_count: 3,
      column_count: 3,
      cells: [1,2,3,4,5,6,7,8,9],
    )
  end

  it "can iterate over cells" do
    expect { |y| subject.each_cell(&y) }.to yield_successive_args(
      [true, 0, 0],
      [nil,  1, 0],
      [nil,  2, 0],
      [nil,  0, 1],
      [nil,  1, 1],
      [nil,  2, 1],
    )
  end
end
