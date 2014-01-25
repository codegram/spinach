# encoding: utf-8

require_relative '../../test_helper'

describe Spinach::Reporter::Stdout do
  let(:exception) { StandardError.new('Something went wrong') }

  let(:error) do
    [stub(name: 'My feature'),
      stub(name: 'A scenario'),
      stub(keyword: 'Keyword', name: 'step name'),
      exception]
  end

  let(:steps) do
    [error]
  end


  before do
    @out = StringIO.new("")
    @error = StringIO.new("")
    @reporter = Spinach::Reporter::Stdout.new(
      output: @out,
      error: @error
    )
  end

  describe '#before_feature_run' do
    it 'outputs the feature' do
      feature = stub_everything(name: 'A cool feature')
      @reporter.before_feature_run(feature)

      @out.string.must_include 'Feature'
      @out.string.must_include 'A cool feature'
    end
  end

  describe '#before_scenario_run' do
    it 'outputs the scenario' do
      scenario = stub_everything(name: 'Arbitrary scenario', steps: [])
      @reporter.before_scenario_run(scenario)

      @out.string.must_include 'Scenario'
      @out.string.must_include 'Arbitrary scenario'
    end
  end

  describe '#after_scenario_run' do
    describe 'in case of error' do
      before do
        @reporter.scenario_error = exception
      end

      it 'reports the full error' do
        @reporter.expects(:report_error).with(exception, :full)

        @reporter.after_scenario_run('name' => 'Arbitrary scenario')
      end

      it 'resets the scenario error' do
        @reporter.stubs(:report_error)
        @reporter.after_scenario_run('name' => 'Arbitrary scenario')

        @reporter.scenario_error.must_equal nil
      end
    end
  end

  describe '#on_successful_step' do
    let(:step) { stub(keyword: 'Given', name: 'I am too cool') }
    let(:step_location){['error_step_location', 1]}
    let(:step_definitions){ stub }
    it 'adds the step to the output buffer' do
      @reporter.on_successful_step(step, step_location)

      @out.string.must_include '✔'
      @out.string.must_include 'Given'
      @out.string.must_include 'am too cool'
    end

    it 'sets the current scenario' do
      @reporter.on_successful_step(step, step_location)

      @reporter.scenario.must_include step
    end

    it 'adds the step to the successful steps' do
      @reporter.on_successful_step(step, step_location)

      @reporter.successful_steps.last.must_include step
    end
  end

  describe '#on_failed_step' do
    let(:step) { stub(keyword: 'Then', name: 'I write failing steps') }
    let(:step_location){['error_step_location', 1]}

    it 'adds the step to the output buffer' do
      @reporter.on_failed_step(step, anything, step_location)

      @out.string.must_include '✘'
      @out.string.must_include 'Then'
      @out.string.must_include 'I write failing steps'
    end

    it 'sets the current scenario error' do
      @reporter.on_failed_step(step, anything, step_location)

      @reporter.scenario_error.must_include step
    end

    it 'adds the step to the failing steps' do
      @reporter.on_failed_step(step, anything, step_location)

      @reporter.failed_steps.last.must_include step
    end
  end

  describe '#on_error_step' do
    let(:step) { stub(keyword: 'And', name: 'I even make syntax errors') }
    let(:step_location){['error_step_location', 1]}

    it 'adds the step to the output buffer' do
      @reporter.on_error_step(step, anything, step_location)

      @out.string.must_include '!'
      @out.string.must_include 'And'
      @out.string.must_include 'I even make syntax errors'
    end

    it 'sets the current scenario error' do
      @reporter.on_error_step(step, anything, step_location)
      @reporter.scenario_error.must_include step
    end

    it 'adds the step to the error steps' do
      @reporter.on_error_step(step, anything, step_location)
      @reporter.error_steps.last.must_include step
    end
  end

  describe '#on_undefined_step' do
    let(:step) { stub(keyword: 'When', name: 'I forgot to write steps') }

    it 'adds the step to the output buffer' do
      @reporter.on_undefined_step(step, anything)

      @out.string.must_include '?'
      @out.string.must_include 'When'
      @out.string.must_include 'I forgot to write steps'
    end

    it 'sets the current scenario error' do
      @reporter.on_undefined_step(step, anything)

      @reporter.scenario_error.must_include step
    end

    it 'adds the step to the undefined steps' do
      @reporter.on_undefined_step(step, anything)

      @reporter.undefined_steps.last.must_include step
    end
  end

  describe '#on_pending_step' do
    let(:step) { stub(keyword: 'Given', name: 'I wrote a pending step') }

    it 'adds the step to the output buffer' do
     @reporter.on_pending_step(step, anything)

     @out.string.must_include 'P'
     @out.string.must_include 'Given'
     @out.string.must_include 'I wrote a pending step'
    end

    it 'sets the current scenario error' do
      @reporter.on_pending_step(step, anything)
      @reporter.scenario_error.must_include step
    end

    it 'adds the step to the pending steps' do
      @reporter.on_pending_step(step, anything)
      @reporter.pending_steps.last.must_include step
    end
  end

  describe "#on_feature_not_found" do
    before do
      @feature = stub(name: 'This feature does not exist', scenarios: [], background_steps: [])
      Spinach.config.stubs(:step_definitions_path).returns('my/path')
      @reporter.on_feature_not_found(@feature)
    end
    it "outputs a message" do
      @out.string.must_include "This feature does not exist"
      @out.string.must_include "this_feature_does_not_exist.rb"
      @out.string.must_include "ThisFeatureDoesNotExist"
      @reporter.undefined_features.must_include @feature
    end

    it 'tells the user to create the file' do
      @out.string.must_include 'Please create the file this_feature_does_not_exist.rb'
    end

    it 'tells the user where to create the file respecting the step definitions path' do
      @out.string.must_include 'at my/path, with:'
    end

    it 'tells the user what to write in the file' do
      @out.string.must_include 'This feature does not exist'
    end
  end

  describe '#on_skipped_step' do
    it 'adds the step to the output buffer' do
      @reporter.on_skipped_step(stub(keyword: 'Then', name: 'some steps are not even called'))

      @out.string.must_include '~'
      @out.string.must_include 'Then'
      @out.string.must_include 'some steps are not even called'
    end
  end

  describe '#output_step' do
    it 'adds a step to the output buffer with nice colors' do
      step = stub(keyword: 'Keyword', name: 'step name')
      @reporter.output_step('symbol', step, :blue)

      @out.string.must_include 'symbol'
      @out.string.must_include 'Keyword'
      @out.string.must_include 'step name'
    end
  end

  describe '#after_run' do
    describe 'when the run has succeed' do
      it 'display run summary' do
        @reporter.expects(:error_summary).never
        @reporter.expects(:run_summary)

        @reporter.after_run(true)
      end
    end

    describe 'when the run has failed' do
      it 'display run and error summaries' do
        @reporter.expects(:error_summary)
        @reporter.expects(:run_summary)

        @reporter.after_run(false)
      end
    end
  end

  describe '#full_step' do
    it 'returns the step with keyword and name' do
      @reporter.full_step(stub(keyword: 'Keyword', name: 'step name')).must_equal 'Keyword step name'
    end
  end
end
