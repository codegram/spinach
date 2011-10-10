# encoding: utf-8

require_relative '../../test_helper'

describe Spinach::Reporter::Stdout do
  let(:exception) { StandardError.new('Something went wrong') }

  let(:error) do
    [{'name' => 'My feature'},
      {'name' => 'A scenario'},
      {'keyword' => 'Keyword', 'name' => 'step name'},
      exception]
  end

  let(:steps) do
    [error]
  end


  before do
    @out = StringIO.new
    @error = StringIO.new
    @reporter = Spinach::Reporter::Stdout.new(
      output: @out,
      error: @error
    )
  end

  describe '#before_feature_run' do
    it 'outputs the feature' do
      @reporter.before_feature_run('name' => 'A cool feature')

      @out.string.must_include 'Feature'
      @out.string.must_include 'A cool feature'
    end
  end

  describe '#before_scenario_run' do
    it 'outputs the scenario' do
      @reporter.before_scenario_run('name' => 'Arbitrary scenario')

      @out.string.must_include 'Scenario'
      @out.string.must_include 'Arbitrary scenario'
    end
  end

  describe '#after_scenario_run' do
    describe 'in case of error' do
      let(:exception) { anything }

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
    let(:step_location){['error_step_location', 1]}
    it 'adds the step to the output buffer' do
      @reporter.on_successful_step({'keyword' => 'Given', 'name' => 'I am too cool'}, step_location)

      @out.string.must_include '✔'
      @out.string.must_include 'Given'
      @out.string.must_include 'am too cool'
    end
  end

  describe '#on_failed_step' do
    let(:step) { {'keyword' => 'Then', 'name' => 'I write failing steps'} }
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
    let(:step) { {'keyword' => 'And', 'name' => 'I even make syntax errors'} }
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
    let(:step) { {'keyword' => 'When', 'name' => 'I forgot to write steps'} }

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

  describe "#on_feature_not_found" do
    before do
      @feature = {
        'name' => 'This feature does not exist'
      }
      Spinach.config.stubs(:step_definitions_path).returns('my/path')
      exception = stub(
        message: "This is a \nmultiple line error message",
        missing_class: "ThisFeatureDoesNotExist"
      )
      @reporter.on_feature_not_found(@feature, exception)
    end
    it "outputs a message" do
      @out.string.must_include "this_feature_does_not_exist.rb"
      @out.string.must_include "This is a"
      @out.string.must_include "multiple line error message"
      @reporter.undefined_features.must_include @feature
    end

    it 'tells the user to create the file' do
      @out.string.must_include 'Please create the file this_feature_does_not_exist.rb'
    end

    it 'tells the user where to create the file respecting the step definitions path' do
      @out.string.must_include 'at my/path, with:'
    end

    it 'tells the user what to write in the file' do
      @out.string.must_include 'Feature \'This feature does not exist\' do'
    end
  end

  describe '#on_skipped_step' do
    it 'adds the step to the output buffer' do
      @reporter.on_skipped_step({'keyword' => 'Then', 'name' => 'some steps are not even called'})

      @out.string.must_include '~'
      @out.string.must_include 'Then'
      @out.string.must_include 'some steps are not even called'
    end
  end

  describe '#output_step' do
    it 'adds a step to the output buffer with nice colors' do
      step = {'keyword' => 'Keyword', 'name' => 'step name'}
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

  describe '#error_summary' do
    it 'prints a summary with all the errors' do
      @reporter.expects(:report_error_steps).once
      @reporter.expects(:report_failed_steps).once
      @reporter.expects(:report_undefined_steps).once
      @reporter.expects(:report_undefined_features).once

      @reporter.error_summary

      @error.string.must_include 'Error summary'
    end
  end

  describe '#report_error_steps' do
    describe 'when some steps have raised an error' do
      it 'outputs the errors' do
        steps = [anything]
        @reporter.stubs(:error_steps).returns(steps)
        @reporter.expects(:report_errors).with('Errors', steps, :light_red)

        @reporter.report_error_steps
      end
    end

    describe 'when there are no error steps' do
      it 'does nothing' do
        @reporter.expects(:report_errors).never

        @reporter.report_error_steps
      end
    end
  end

  describe '#report_failed_steps' do
    describe 'when some steps have failed' do
      it 'outputs the failing steps' do
        steps = [anything]
        @reporter.stubs(:failed_steps).returns(steps)
        @reporter.expects(:report_errors).with('Failures', steps, :light_red)

        @reporter.report_failed_steps
      end
    end

    describe 'when there are no failed steps' do
      it 'does nothing' do
        @reporter.expects(:report_errors).never

        @reporter.report_failed_steps
      end
    end
  end

  describe '#report_undefined_steps' do
    describe 'when some steps have undefined' do
      it 'outputs the failing steps' do
        steps = [anything]
        @reporter.stubs(:undefined_steps).returns(steps)
        @reporter.expects(:report_errors).with('Undefined steps', steps, :yellow)

        @reporter.report_undefined_steps
      end
    end

    describe 'when there are no undefined steps' do
      it 'does nothing' do
        @reporter.expects(:report_errors).never

        @reporter.report_undefined_steps
      end
    end
  end

  describe '#report_undefined_features' do
    describe 'when some features are undefined' do
      it 'outputs the undefined features' do
        @reporter.undefined_features << {'name' => 'Undefined feature name'}
        @reporter.report_undefined_features

        @error.string.must_include "Undefined features (1)"
        @error.string.must_include "Undefined feature name"
      end
    end

    describe 'when there are no undefined features' do
      it 'does nothing' do
        error = @error.string.dup
        @reporter.report_undefined_steps

        error.must_equal @error.string
      end
    end
  end

  describe '#report_errors' do
    describe 'when some steps have raised an error' do
      it 'outputs a the banner with the number of steps given' do
        @reporter.report_errors('Banner', steps, :blue)

        @error.string.must_include 'Banner (1)'
      end

      it 'prints a summarized error' do
        @reporter.report_errors('Banner', steps, :blue)

        @error.string.must_include 'My feature :: A scenario :: Keyword step name'
      end

      it 'colorizes the output' do
        String.any_instance.expects(:colorize).with(:blue).at_least_once

        @reporter.report_errors('Banner', [], :blue)
      end
    end
  end

  describe '#report_error' do
    it 'raises when given an unsupported format' do
      proc {
        @reporter.report_error(error, :nil)
      }.must_raise RuntimeError, 'Format not defined'
    end

    it 'prints a summarized error by default' do
      @reporter.expects(:summarized_error).with(error).returns('summarized error')

      @reporter.report_error(error)

      @error.string.must_include 'summarized error'
    end

    it 'prints a summarized error' do
      @reporter.expects(:summarized_error).with(error).returns('summarized error')

      @reporter.report_error(error, :summarized)

      @error.string.must_include 'summarized error'
    end

    it 'prints a full error' do
      @reporter.expects(:full_error).with(error).returns('full error')

      @reporter.report_error(error, :full)

      @error.string.must_include 'full error'
    end
  end

  describe '#summarized_error' do
    it 'prints the error' do
      summary = @reporter.summarized_error(error)

      summary.must_include 'My feature :: A scenario :: Keyword step name'
    end

    it 'colorizes the print' do
      String.any_instance.expects(:red)

      @reporter.summarized_error(error)
    end

    describe 'when given an undefined step exception' do
      it 'prints the error in yellow' do
        undefined_error = error
        undefined_error.insert(3, Spinach::StepNotDefinedException.new(anything, anything))

        String.any_instance.expects(:yellow)

        @reporter.summarized_error(error)
      end
    end
  end

  describe '#full_error' do
    before do
      @reporter.expects(:report_exception).with(exception).returns('Exception backtrace')
    end

    it 'returns the exception data' do
      exception.expects(:backtrace).returns(['first backtrace line'])
      output = @reporter.full_error(error)

      output.must_include 'Exception backtrace'
    end

    it 'returns the first backtrace line' do
      exception.expects(:backtrace).returns(['first backtrace line'])
      output = @reporter.full_error(error)

      output.must_include 'first backtrace line'
    end

    describe 'when the user wants to print the full backtrace' do
      it 'prints the full backtrace' do
        @reporter.stubs(:options).returns({backtrace: true})
        exception.expects(:backtrace).returns(['first backtrace line', 'second backtrace line'])

        output = @reporter.full_error(error)

        output.must_include 'first backtrace line'
        output.must_include 'second backtrace line'
      end
    end
  end

  describe '#full_step' do
    it 'returns the step with keyword and name' do
      @reporter.full_step({'keyword' => 'Keyword', 'name' => 'step name'}).must_equal 'Keyword step name'
    end

    it 'strips the arguments' do
      @reporter.full_step({'keyword' => '   Keyword    ', 'name' => '   step name   '}).must_equal 'Keyword step name'
    end
  end

  describe '#report_exception' do
    it 'returns the exception data' do
      output = @reporter.report_exception(exception)

      output.must_include 'Something went wrong'
    end

    it 'colorizes the print' do
      String.any_instance.expects(:red)

      @reporter.report_exception(exception)
    end

    describe 'when given an undefined step exception' do
      it 'prints the error in yellow' do
        undefined_exception = Spinach::StepNotDefinedException.new(anything, anything)

        String.any_instance.expects(:yellow)

        @reporter.report_exception(undefined_exception)
      end
    end
  end
end
