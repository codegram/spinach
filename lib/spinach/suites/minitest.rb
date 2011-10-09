MiniTest::Spec.new nil
Spinach.config[:failure_exceptions] << MiniTest::Assertion
Spinach::FeatureSteps.send(:include, MiniTest::Assertions)
