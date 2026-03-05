# frozen_string_literal: true

# Generates a formatted receipt from a list of LineItems.
# Receipt only knows about presentation: all tax computation
# has already been done upstream.
class Receipt
  def initialize(line_items)
    @line_items = line_items
  end

  def total_taxes
    @line_items.sum(&:tax)
  end

  def total
    @line_items.sum(&:total_price)
  end

  def to_s
    lines = @line_items.map { |li| format_line(li) }
    lines << "Sales Taxes: #{format_price(total_taxes)}"
    lines << "Total: #{format_price(total)}"
    lines.join("\n")
  end

  private

  def format_line(line_item)
    "#{line_item.quantity} #{line_item.name}: #{format_price(line_item.total_price)}"
  end

  def format_price(amount)
    format("%.2f", amount)
  end
end
