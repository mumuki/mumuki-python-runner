require_relative './query_hook_shared_examples'
require_relative './test_hook_shared_examples'
require_relative './expectations_hook_shared_examples'
require_relative './integration_shared_examples'

RSpec.configure do |rspec|
  rspec.expect_with :rspec do |c|
    c.max_formatted_output_length = nil
  end
end