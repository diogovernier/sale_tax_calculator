# frozen_string_literal: true

# Represents a single line on a receipt, an item with its tax already calculated.
# This is the output of applying tax rules to an Item.
class LineItem
  attr_reader :name, :quantity, :total_price, :tax

  def initialize(name:, quantity:, total_price:, tax:)
    @name = name
    @quantity = quantity
    @total_price = total_price
    @tax = tax
  end
end
