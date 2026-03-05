# frozen_string_literal: true

RSpec.describe InputParser do
  subject(:parser) { described_class.new }

  describe "#parse" do
    it "parses a single domestic item" do
      items = parser.parse("1 music CD at 14.99")

      expect(items.length).to eq(1)
      expect(items[0].name).to eq("music CD")
      expect(items[0].unit_price).to eq(BigDecimal("14.99"))
      expect(items[0].quantity).to eq(1)
      expect(items[0].imported?).to be false
    end

    it "parses a quantity greater than 1" do
      items = parser.parse("2 book at 12.49")

      expect(items[0].quantity).to eq(2)
      expect(items[0].name).to eq("book")
    end

    it "detects imported items from the name" do
      items = parser.parse("1 imported bottle of perfume at 27.99")

      expect(items[0].imported?).to be true
      expect(items[0].name).to eq("imported bottle of perfume")
    end

    it "parses multiple lines" do
      input = <<~INPUT
        2 book at 12.49
        1 music CD at 14.99
        1 chocolate bar at 0.85
      INPUT

      items = parser.parse(input)
      expect(items.length).to eq(3)
    end

    it "skips blank lines" do
      input = "1 book at 12.49\n\n1 music CD at 14.99\n"
      items = parser.parse(input)
      expect(items.length).to eq(2)
    end

    it "raises an error for invalid input" do
      expect { parser.parse("invalid line") }.to raise_error(ArgumentError, /Invalid input line/)
    end
  end
end
