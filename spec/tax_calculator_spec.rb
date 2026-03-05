# frozen_string_literal: true

RSpec.describe TaxCalculator do
  subject(:calculator) { described_class.new }

  def build_item(name:, unit_price:, quantity: 1, imported: false)
    Item.new(name: name, unit_price: BigDecimal(unit_price), quantity: quantity, imported: imported)
  end

  describe "#calculate" do
    context "when the item is exempt and domestic" do
      it "returns zero tax for a book" do
        result = calculator.calculate(build_item(name: "book", unit_price: "12.49"))

        expect(result.tax).to eq(BigDecimal("0"))
        expect(result.total_price).to eq(BigDecimal("12.49"))
      end

      it "returns zero tax for food (chocolate bar)" do
        result = calculator.calculate(build_item(name: "chocolate bar", unit_price: "0.85"))

        expect(result.tax).to eq(BigDecimal("0"))
      end

      it "returns zero tax for medical products (headache pills)" do
        result = calculator.calculate(build_item(name: "packet of headache pills", unit_price: "9.75"))

        expect(result.tax).to eq(BigDecimal("0"))
      end
    end

    context "when the item is non-exempt and domestic" do
      it "applies 10% basic sales tax (music CD at 14.99)" do
        result = calculator.calculate(build_item(name: "music CD", unit_price: "14.99"))

        expect(result.tax).to eq(BigDecimal("1.50"))
        expect(result.total_price).to eq(BigDecimal("16.49"))
      end

      it "applies 10% basic sales tax (perfume at 18.99)" do
        result = calculator.calculate(build_item(name: "bottle of perfume", unit_price: "18.99"))

        expect(result.tax).to eq(BigDecimal("1.90"))
        expect(result.total_price).to eq(BigDecimal("20.89"))
      end
    end

    context "when the item is exempt and imported" do
      it "applies only 5% import duty (imported chocolates at 10.00)" do
        result = calculator.calculate(build_item(name: "imported box of chocolates", unit_price: "10.00", imported: true))

        expect(result.tax).to eq(BigDecimal("0.50"))
        expect(result.total_price).to eq(BigDecimal("10.50"))
      end

      it "applies only 5% import duty (imported chocolates at 11.25)" do
        result = calculator.calculate(build_item(name: "imported boxes of chocolates", unit_price: "11.25", imported: true))

        expect(result.tax).to eq(BigDecimal("0.60"))
      end
    end

    context "when the item is non-exempt and imported" do
      it "applies 15% combined tax (imported perfume at 47.50)" do
        result = calculator.calculate(build_item(name: "imported bottle of perfume", unit_price: "47.50", imported: true))

        expect(result.tax).to eq(BigDecimal("7.15"))
        expect(result.total_price).to eq(BigDecimal("54.65"))
      end

      it "applies 15% combined tax (imported perfume at 27.99)" do
        result = calculator.calculate(build_item(name: "imported bottle of perfume", unit_price: "27.99", imported: true))

        expect(result.tax).to eq(BigDecimal("4.20"))
        expect(result.total_price).to eq(BigDecimal("32.19"))
      end
    end

    context "when the item has quantity > 1" do
      it "multiplies per-unit tax by quantity" do
        result = calculator.calculate(build_item(name: "imported boxes of chocolates", unit_price: "11.25", quantity: 3, imported: true))

        expect(result.tax).to eq(BigDecimal("1.80"))
        expect(result.total_price).to eq(BigDecimal("35.55"))
      end

      it "calculates correct total for multiple exempt domestic items" do
        result = calculator.calculate(build_item(name: "book", unit_price: "12.49", quantity: 2))

        expect(result.tax).to eq(BigDecimal("0"))
        expect(result.total_price).to eq(BigDecimal("24.98"))
      end
    end

    it "returns a LineItem with the correct name and quantity" do
      result = calculator.calculate(build_item(name: "music CD", unit_price: "14.99"))

      expect(result).to be_a(LineItem)
      expect(result.name).to eq("music CD")
      expect(result.quantity).to eq(1)
    end
  end

  describe "rounding" do
    it "rounds tax up to the nearest 0.05" do
      result = calculator.calculate(build_item(name: "music CD", unit_price: "14.99"))
      expect(result.tax).to eq(BigDecimal("1.50"))
    end

    it "rounds 1.899 up to 1.90" do
      result = calculator.calculate(build_item(name: "bottle of perfume", unit_price: "18.99"))
      expect(result.tax).to eq(BigDecimal("1.90"))
    end

    it "does not round when tax is already on a 0.05 boundary" do
      result = calculator.calculate(build_item(name: "imported box of chocolates", unit_price: "10.00", imported: true))
      expect(result.tax).to eq(BigDecimal("0.50"))
    end

    # 15% of 47.50 = 7.125, must round to nearest 0.05 (7.15), not 0.01 (7.13)
    it "rounds to nearest 0.05, not nearest 0.01" do
      result = calculator.calculate(build_item(name: "imported bottle of perfume", unit_price: "47.50", imported: true))
      expect(result.tax).to eq(BigDecimal("7.15"))
    end

    # 5% of 11.25 = 0.5625, must round to 0.60, not 0.57
    it "rounds 0.5625 up to 0.60, not 0.57" do
      result = calculator.calculate(build_item(name: "imported box of chocolates", unit_price: "11.25", imported: true))
      expect(result.tax).to eq(BigDecimal("0.60"))
    end
  end
end
