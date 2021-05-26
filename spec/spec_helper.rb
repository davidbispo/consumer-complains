require 'rack/test'
require 'byebug'
ENV['RACK_ENV'] = 'test'
require_relative './database_cleaner'

RSpec.configure do |config|
  config.include Rack::Test::Methods

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
    config.formatter = :documentation
    config.tty = true
    config.color = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.before(:all) do
    DatabaseCleaner::start
  end
end
