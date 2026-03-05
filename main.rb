# frozen_string_literal: true

require "bigdecimal"
require "bigdecimal/util"

require_relative "lib/input_parser"
require_relative "lib/tax_calculator"
require_relative "lib/receipt"

# Main entry point for the Sales Tax application.
# Reads shopping basket input from a file (passed as argument) or from STDIN,
# and prints the formatted receipt.
#
# Usage:
#   ruby main.rb data/input1.txt
#   echo "1 book at 12.49" | ruby main.rb

input = if ARGV.any?
          File.read(ARGV[0])
        else
          $stdin.read
        end

parser = InputParser.new
calculator = TaxCalculator.new

items = parser.parse(input)
line_items = items.map { |item| calculator.calculate(item) }
receipt = Receipt.new(line_items)

puts receipt
