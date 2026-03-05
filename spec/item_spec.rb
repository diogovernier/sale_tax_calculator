# frozen_string_literal: true

RSpec.describe Item do
  describe "#initialize" do
    it "stores name, unit_price, quantity, and imported status" do
      item = Item.new(name: "book", unit_price: BigDecimal("12.49"), quantity: 2, imported: false)

      expect(item.name).to eq("book")
      expect(item.unit_price).to eq(BigDecimal("12.49"))
      expect(item.quantity).to eq(2)
      expect(item.imported?).to be false
    end

    it "defaults imported to false" do
      item = Item.new(name: "book", unit_price: BigDecimal("12.49"), quantity: 1)

      expect(item.imported?).to be false
    end
  end

  describe "#imported?" do
    it "returns true when item is imported" do
      item = Item.new(name: "imported perfume", unit_price: BigDecimal("27.99"), quantity: 1, imported: true)

      expect(item.imported?).to be true
    end

    it "returns false when item is not imported" do
      item = Item.new(name: "perfume", unit_price: BigDecimal("18.99"), quantity: 1, imported: false)

      expect(item.imported?).to be false
    end
  end
end
