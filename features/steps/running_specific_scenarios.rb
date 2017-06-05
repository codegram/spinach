class Spinach::Features::RunningSpecificScenarios < Spinach::FeatureSteps
  include Integration::SpinachRunner

  Given 'I have a feature with 2 scenarios' do
    @feature = Integration::FeatureGenerator.failure_feature_with_two_scenarios
  end

  When 'I specify that only the second should be run' do
    feature_file = Pathname.new(Filesystem.dirs.first).join(@feature)
    step_lines   = feature_file.each_line.with_index.select do |line, index|
      line.match(/^\s*Then/)
    end

    line_number = step_lines[1].last

    run_feature("#{@feature}:#{line_number}")
  end

  Then 'One will succeed and none will fail' do
    @stdout.must_match("(1) Successful")
    @stdout.must_match("(0) Failed")
    @stdout.must_match("(0) Pending")    
  end

  Given 'I have a tagged feature with 2 scenarios' do
    @feature = Integration::FeatureGenerator.tagged_failure_feature_with_two_scenarios
  end

  When 'I include the tag of the failing scenario' do
    run_feature(@feature, {append: "-t @failing"})
  end

  Then 'None will succeed and one will fail' do
    @stdout.must_match("(0) Successful")
    @stdout.must_match("(1) Failed")
    @stdout.must_match("(0) Pending")
  end

  When 'I exclude the tag of the passing scenario' do
    run_feature(@feature, {append: "-t ~@passing"})
  end

  When 'I include the tag of the feature and exclude the tag of the failing scenario' do
    run_feature(@feature, {append: "-t @feature,~@failing"})
  end
end
