describe Calculator do
  it "can add" do
    calculator = Calculator.new
    expect(calculator.add(1, 1)).to eq(2)
  end
end
