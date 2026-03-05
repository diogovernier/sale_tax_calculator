# frozen_string_literal: true

require "bigdecimal"
require "bigdecimal/util"

require_relative "line_item"

# Calculates sales tax for an Item based on tax rules:
#   - Basic sales tax: 10% on all goods except exempt categories (books, food, medical).
#   - Import duty: 5% on all imported goods, with no exemptions.
#   - Rounding: tax is rounded up to the nearest 0.05.
#
# Returns a LineItem with the computed tax and total price.
class TaxCalculator
  BASIC_TAX_RATE = BigDecimal("0.10")
  IMPORT_DUTY_RATE = BigDecimal("0.05")
  ROUNDING_INCREMENT = BigDecimal("0.05")

  EXEMPT_KEYWORDS = %w[book chocolate chocolates pill pills food candy sweet cream bread rice water juice].freeze

  def calculate(item)
    tax = tax_for(item)
    total_price = (item.unit_price * item.quantity) + tax

    LineItem.new(
      name: item.name,
      quantity: item.quantity,
      total_price: total_price,
      tax: tax
    )
  end

  private

  def tax_for(item)
    rate = applicable_rate(item)
    round_tax(item.unit_price * rate) * item.quantity
  end

  def applicable_rate(item)
    rate = BigDecimal("0")
    rate += BASIC_TAX_RATE unless exempt?(item)
    rate += IMPORT_DUTY_RATE if item.imported?
    rate
  end

  def exempt?(item)
    name = item.name.downcase
    EXEMPT_KEYWORDS.any? { |keyword| name.include?(keyword) }
  end

  # Rounds a tax amount up to the nearest 0.05.
  def round_tax(amount)
    (amount / ROUNDING_INCREMENT).ceil * ROUNDING_INCREMENT
  end
end
