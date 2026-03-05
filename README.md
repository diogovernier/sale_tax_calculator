# Sales Tax Calculator

A Ruby application that calculates sales tax and import duty for shopping basket items and produces formatted receipts.

## Requirements

- Ruby 4.0+ (tested with Ruby 4.0.1)
- Bundler (for running tests)

## Setup

```bash
bundle install
```

## Running the Application

The application accepts input from a file or from STDIN.

**From a file:**

```bash
ruby main.rb data/input1.txt
ruby main.rb data/input2.txt
ruby main.rb data/input3.txt
```

**From STDIN:**

```bash
echo "1 book at 12.49" | ruby main.rb
```

Or interactively (press Ctrl+D when done):

```bash
ruby main.rb
2 book at 12.49
1 music CD at 14.99
1 chocolate bar at 0.85
^D
```

## Running the Tests

```bash
bundle exec rspec
```

## Project Structure

```
├── main.rb                    # Entry point: reads input, wires components, prints receipt
├── lib/
│   ├── item.rb                # Value object representing a product in the basket (input)
│   ├── line_item.rb           # Value object representing a receipt line (output of tax calc)
│   ├── tax_calculator.rb      # Calculates tax based on item type and import status
│   ├── input_parser.rb        # Parses text input into Item objects
│   └── receipt.rb             # Formats LineItems into receipt output
├── spec/
│   ├── spec_helper.rb         # RSpec configuration
│   ├── item_spec.rb           # Unit tests for Item
│   ├── line_item_spec.rb      # Unit tests for LineItem
│   ├── tax_calculator_spec.rb # Unit tests for TaxCalculator (rates, rounding, exemptions)
│   ├── input_parser_spec.rb   # Unit tests for InputParser
│   └── receipt_spec.rb        # Integration tests verifying all 3 expected outputs
├── data/
│   ├── input1.txt            # Sample input 1
│   ├── input2.txt            # Sample input 2
│   └── input3.txt            # Sample input 3
├── Gemfile                   # Dependencies (rspec only)
└── README.md
```

## Design Decisions

### Composition over Inheritance

Each class has a single responsibility and collaborates with others through composition:

- **Item**: a simple value object holding raw product data (name, price, quantity, imported flag). It has no tax logic.
- **TaxCalculator**: encapsulates all tax rules: exemption checks, rate selection, and rounding. Takes an Item and returns a LineItem with computed tax and total.
- **LineItem**: a value object representing one line on a receipt, with pre-computed tax and total price. This separates "raw input" (Item) from "processed output" (LineItem).
- **InputParser**: converts raw text into Item objects. Decoupled from tax logic and receipt formatting.
- **Receipt**: receives a list of LineItems and formats them. It has no knowledge of tax rules, all computation is done before it gets involved.

This means each class can be tested, modified, or replaced independently. For example, swapping in a different tax regime requires only changing TaxCalculator, Receipt, Item, and InputParser are unaffected.

### BigDecimal for Precision

All monetary calculations use Ruby's `BigDecimal` to avoid floating-point rounding errors. This is critical for financial applications where precision matters.

### Tax Rounding

Per the specification, tax is rounded **up** to the nearest 0.05. This is implemented as:

```ruby
ROUNDING_INCREMENT = BigDecimal("0.05")

(amount / ROUNDING_INCREMENT).ceil * ROUNDING_INCREMENT
```

This divides the tax into 0.05 units, rounds up to the next whole unit, and converts back. We cannot use `BigDecimal#round(n, :ceil)` here because it rounds to a decimal place (0.1 or 0.01), not to an arbitrary increment like 0.05.

Tax is rounded per unit, then multiplied by quantity, matching the expected outputs.

## Assumptions

1. **Exempt categories** are identified by keyword matching against the item name. The keywords cover the categories from the problem statement: books (`book`), food (`chocolate`, `chocolates`, `food`, `candy`, `sweet`, `cream`, `bread`, `rice`, `water`, `juice`), and medical products (`pill`, `pills`).
2. **Imported items** are identified by the presence of the word "imported" in the item name.
3. **Input format** follows the pattern: `<quantity> <name> at <price>` with prices having exactly two decimal places.
4. **Tax rounding is per-unit**: tax is calculated and rounded for a single unit, then multiplied by quantity.
