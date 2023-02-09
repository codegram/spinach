class Spinach::Features::FeatureHooksAndTags < Spinach::FeatureSteps
  include Integration::SpinachRunner

  step 'I have a tagged feature with an untagged scenario' do
    write_file 'features/a.feature', <<-FEATURE
@tag
Feature: A
  Scenario: A1
    Then a1
    FEATURE

    write_file 'features/steps/a.rb', <<-STEPS
class Spinach::Features::A < Spinach::FeatureSteps
  step 'a1' do; end
end
    STEPS
  end

  step 'I have an untagged feature with a tagged scenario' do
    write_file 'features/b.feature', <<-FEATURE
Feature: B
  @tag
  Scenario: B1
    Then b1
    FEATURE

    write_file 'features/steps/b.rb', <<-STEPS
class Spinach::Features::B < Spinach::FeatureSteps
  step 'b1' do; end
end
    STEPS
  end

  step "I don't specify tags" do
    run_spinach
  end

  step 'I specify a tag the features and scenarios are tagged with' do
    run_spinach({append: "--tags @tag"})
  end

  step 'I exclude a tag the features and scenarios are tagged with' do
    run_spinach({append: "--tags ~@tag"})
  end

  step 'all the feature hooks should have run' do
    @stdout.must_match("Feature: A")
    @stdout.must_match("Feature: B")
  end

  step 'no feature hooks should have run' do
    @stdout.wont_match("Feature: A")
    @stdout.wont_match("Feature: B")
  end
end
