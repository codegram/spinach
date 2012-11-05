class UseCustomizedReporter < Spinach::FeatureSteps

  feature "Use customized reporter"

  include Integration::SpinachRunner

  before do
    class_str = <<-EOF
  class Spinach::TestReporter < Spinach::Reporter
    attr_reader :out, :error
    attr_accessor :scenario_error
    attr_accessor :scenario

    def initialize(*args)
      super(*args)
      @out = options[:output] || $stdout
      @error = options[:error] || $stderr
      @max_step_name_length = 0
    end

    def before_feature_run(feature)
      out.puts "The customized class"
    end

    def before_scenario_run(scenario, step_definitions = nil)
    end

    def after_scenario_run(scenario, step_definitions = nil)
    end

    def on_successful_step(step, step_location, step_definitions = nil)
    end

    def on_failed_step(step, failure, step_location, step_definitions = nil)
    end

    def on_error_step(step, failure, step_location, step_definitions = nil)
    end

    def on_undefined_step(step, failure, step_definitions = nil)
    end

    def on_pending_step(step, failure)
    end

    def on_feature_not_found(feature)
    end

    def on_skipped_step(step, step_definitions = nil)
    end

    def output_step(symbol, step, color, step_location = nil)
    end

    def after_run(success)
    end

    def run_summary
    end

    def full_step(step)
    end

  end
    EOF

    write_file "test_reporter.rb", class_str
  end

  Given 'I have a feature that has no error or failure' do
    write_file('features/success_feature.feature', """
Feature: A success feature

  Scenario: This is scenario will succeed
    Then I succeed
               """)

               write_file('features/steps/success_feature.rb',
                          <<-EOF
    require_relative "../../test_reporter"
class ASuccessFeature < Spinach::FeatureSteps
      feature "A success feature"
      Then "I succeed" do
      end
     end
     EOF
)
               @feature = "features/success_feature.feature"
  end

  When 'I run it using the new reporter' do
    run_feature @feature, append: "-r Spinach::TestReporter"
  end

  Then 'I see the desired output' do
    @stdout.must_include("The customized class")
  end
end
