# frozen_string_literal: true

RSpec.describe Receipt do
  let(:calculator) { TaxCalculator.new }
  let(:parser) { InputParser.new }

  def build_receipt(input)
    items = parser.parse(input)
    line_items = items.map { |item| calculator.calculate(item) }
    Receipt.new(line_items)
  end

  describe "Output 1" do
    let(:receipt) do
      build_receipt(<<~INPUT)
        2 book at 12.49
        1 music CD at 14.99
        1 chocolate bar at 0.85
      INPUT
    end

    it "calculates the correct total taxes" do
      expect(receipt.total_taxes).to eq(BigDecimal("1.50"))
    end

    it "calculates the correct total" do
      expect(receipt.total).to eq(BigDecimal("42.32"))
    end

    it "produces the expected receipt output" do
      expected = <<~OUTPUT.chomp
        2 book: 24.98
        1 music CD: 16.49
        1 chocolate bar: 0.85
        Sales Taxes: 1.50
        Total: 42.32
      OUTPUT

      expect(receipt.to_s).to eq(expected)
    end
  end

  describe "Output 2" do
    let(:receipt) do
      build_receipt(<<~INPUT)
        1 imported box of chocolates at 10.00
        1 imported bottle of perfume at 47.50
      INPUT
    end

    it "calculates the correct total taxes" do
      expect(receipt.total_taxes).to eq(BigDecimal("7.65"))
    end

    it "calculates the correct total" do
      expect(receipt.total).to eq(BigDecimal("65.15"))
    end

    it "produces the expected receipt output" do
      expected = <<~OUTPUT.chomp
        1 imported box of chocolates: 10.50
        1 imported bottle of perfume: 54.65
        Sales Taxes: 7.65
        Total: 65.15
      OUTPUT

      expect(receipt.to_s).to eq(expected)
    end
  end

  describe "Output 3" do
    let(:receipt) do
      build_receipt(<<~INPUT)
        1 imported bottle of perfume at 27.99
        1 bottle of perfume at 18.99
        1 packet of headache pills at 9.75
        3 imported boxes of chocolates at 11.25
      INPUT
    end

    it "calculates the correct total taxes" do
      expect(receipt.total_taxes).to eq(BigDecimal("7.90"))
    end

    it "calculates the correct total" do
      expect(receipt.total).to eq(BigDecimal("98.38"))
    end

    it "produces the expected receipt output" do
      expected = <<~OUTPUT.chomp
        1 imported bottle of perfume: 32.19
        1 bottle of perfume: 20.89
        1 packet of headache pills: 9.75
        3 imported boxes of chocolates: 35.55
        Sales Taxes: 7.90
        Total: 98.38
      OUTPUT

      expect(receipt.to_s).to eq(expected)
    end
  end

  describe "#total_taxes" do
    it "returns zero when all items are exempt" do
      line_items = [
        LineItem.new(name: "book", quantity: 1, total_price: BigDecimal("10.00"), tax: BigDecimal("0")),
        LineItem.new(name: "chocolate", quantity: 1, total_price: BigDecimal("5.00"), tax: BigDecimal("0"))
      ]
      receipt = Receipt.new(line_items)

      expect(receipt.total_taxes).to eq(BigDecimal("0"))
    end
  end
end
