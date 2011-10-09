MiniTest::Spec.new nil if defined?(MiniTest::Spec)
Spinach.config[:failure_exceptions] << MiniTest::Assertion
Spinach::FeatureSteps.send(:include, MiniTest::Assertions)
