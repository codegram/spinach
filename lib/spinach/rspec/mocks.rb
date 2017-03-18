# Inspired by cucumber/rspec/mocks
require 'rspec/mocks'

class Spinach::FeatureSteps
  include RSpec::Mocks::ExampleMethods
end

Spinach.hooks.before_scenario do
  RSpec::Mocks.setup
end

Spinach.hooks.after_scenario do
  begin
    RSpec::Mocks.verify
  ensure
    RSpec::Mocks.teardown
  end
end
