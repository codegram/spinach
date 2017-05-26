class Spinach::Features::RunningSpecificScenarios < Spinach::FeatureSteps
  include Integration::SpinachRunner

  step 'I have a feature with 2 passing scenarios' do
    @feature = Integration::FeatureGenerator.success_feature_with_two_scenarios
  end

  step 'I specify that only the second should be run' do
    feature_file = Pathname.new(Filesystem.dirs.first)/@feature
    step_lines   = feature_file.each_line.with_index.select do |line, index|
      line.match(/^\s*Then/)
    end

    line_number = step_lines[1].last

    run_feature("#{@feature}:#{line_number}")
  end

  step 'Only the second should be run' do
    @stdout.must_match("(1) Successful")
    @stdout.must_match("(0) Failed")
    @stdout.must_match("(0) Pending")
  end
end
