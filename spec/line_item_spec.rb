# frozen_string_literal: true

RSpec.describe LineItem do
  it "stores name, quantity, total_price, and tax" do
    line_item = LineItem.new(
      name: "music CD",
      quantity: 1,
      total_price: BigDecimal("16.49"),
      tax: BigDecimal("1.50")
    )

    expect(line_item.name).to eq("music CD")
    expect(line_item.quantity).to eq(1)
    expect(line_item.total_price).to eq(BigDecimal("16.49"))
    expect(line_item.tax).to eq(BigDecimal("1.50"))
  end
end
