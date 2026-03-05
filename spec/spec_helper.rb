# frozen_string_literal: true

require "bigdecimal"
require "bigdecimal/util"

require_relative "../lib/item"
require_relative "../lib/line_item"
require_relative "../lib/tax_calculator"
require_relative "../lib/input_parser"
require_relative "../lib/receipt"

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end
