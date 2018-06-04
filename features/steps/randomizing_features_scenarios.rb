class Spinach::Features::RandomizingFeaturesScenarios < Spinach::FeatureSteps
  include Integration::SpinachRunner

  step 'I have 2 features with 2 scenarios each' do
    write_file 'features/success_a.feature', <<-FEATURE
Feature: Success A
  Scenario: A1
    Then a1
  Scenario: A2
    Then a2
    FEATURE

    write_file 'features/steps/success_a.rb', <<-STEPS
class Spinach::Features::SuccessA < Spinach::FeatureSteps
  step 'a1' do; end
  step 'a2' do; end
end
    STEPS

    write_file 'features/success_b.feature', <<-FEATURE
Feature: Success B
  Scenario: B1
    Then b1
  Scenario: B2
    Then b2
    FEATURE

    write_file 'features/steps/success_b.rb', <<-STEPS
class Spinach::Features::SuccessB < Spinach::FeatureSteps
  step 'b1' do; end
  step 'b2' do; end
end
    STEPS
  end

  step 'I randomize the run without specifying a seed' do
    run_spinach({append: "--rand"})
  end

  step 'I specify the seed for the run' do
    # Reverse order (A2 A1 B2 B1) is the only way I can show that
    # scenarios and features are randomized by the seed when the
    # example has 2 features each with 2 scenarios. I tried seeds
    # until I found one that ordered the test in that order.
    @seed = 1

    run_spinach({append: "--seed #{@seed}"})
  end

  step 'The features and scenarios are run' do
    @stdout.must_include("A1")
    @stdout.must_include("A2")
    @stdout.must_include("B1")
    @stdout.must_include("B2")
  end

  step 'The features and scenarios are run in a different order' do
    @stdout.must_match(/B2.*B1.*A2.*A1/m)
  end

  step 'The runner output shows a seed' do
    @stdout.must_match(/^Randomized with seed \d*$/)
  end

  step 'The runner output shows the seed' do
    @stdout.must_match(/^Randomized with seed #{@seed}$/)
  end
end
