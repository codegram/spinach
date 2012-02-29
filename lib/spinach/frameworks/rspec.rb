Spinach.config[:failure_exceptions] << RSpec::Expectations::ExpectationNotMetError
Spinach::FeatureSteps.send(:include, RSpec::Matchers)
