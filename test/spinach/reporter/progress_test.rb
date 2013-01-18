# encoding: utf-8

require_relative '../../test_helper'

describe Spinach::Reporter::Progress do
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
    @out = StringIO.new
    @error = StringIO.new
    @reporter = Spinach::Reporter::Progress.new(
      output: @out,
      error: @error
    )
  end

  describe '#on_successful_step' do
    let(:step) { stub(keyword: 'Given', name: 'I am too cool') }
    let(:step_location){['error_step_location', 1]}
    let(:step_definitions){ stub }

    it 'adds the step to the output buffer' do
      @reporter.on_successful_step(step, step_location)

      @out.string.must_include '.'
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

      @out.string.must_include 'F'
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

      @out.string.must_include 'E'
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

      @out.string.must_include 'U'
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

  describe '#on_skipped_step' do
    it 'adds the step to the output buffer' do
      @reporter.on_skipped_step(stub(keyword: 'Then', name: 'some steps are not even called'))

      @out.string.must_include '~'
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
end

