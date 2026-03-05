# frozen_string_literal: true

# Represents a single product in a shopping basket.
# An Item knows its name, unit price, quantity, and whether it is imported.
class Item
  attr_reader :name, :unit_price, :quantity, :imported

  def initialize(name:, unit_price:, quantity:, imported: false)
    @name = name
    @unit_price = unit_price
    @quantity = quantity
    @imported = imported
  end

  def imported?
    @imported
  end
end
