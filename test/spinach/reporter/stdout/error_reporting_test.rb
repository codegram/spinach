# encoding: utf-8

require_relative '../../../test_helper'

describe Spinach::Reporter::Stdout do
  let(:exception) do
    mock "exception" do
      stubs(:message).returns "Something went wrong"
    end
  end

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
    @reporter = Spinach::Reporter::Stdout.new(
      output: @out,
      error: @error
    )
  end

  describe '#error_summary' do
    it 'prints a summary with all the errors' do
      @reporter.expects(:report_error_steps).once
      @reporter.expects(:report_failed_steps).once
      @reporter.expects(:report_undefined_steps).once
      @reporter.expects(:report_undefined_features).once
      @reporter.expects(:report_pending_steps).once

      @reporter.error_summary

      @error.string.must_include 'Error summary'
    end
  end

  describe '#run_summary' do
    it 'prints a run summary' do
      @reporter.run_summary

      @out.string.must_include 'Steps Summary:'
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
        @reporter.expects(:report_errors).with('Undefined steps', steps, :red)

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

  describe '#report_pending_steps' do
    describe 'when some steps have pending' do
      it 'outputs the pending steps' do
        steps = [anything]
        @reporter.stubs(:pending_steps).returns(steps)
        @reporter.expects(:report_errors).with('Pending steps', steps, :yellow)

        @reporter.report_pending_steps
      end
    end

    describe 'when there are no pending steps' do
      it 'does nothing' do
        @reporter.expects(:report_errors).never
        @reporter.report_pending_steps
      end
    end
  end

  describe '#report_undefined_features' do
    describe 'when some features are undefined' do
      it 'outputs the undefined features' do
        @reporter.undefined_features << stub(name: 'Undefined feature name')
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
      it 'prints the error in red' do
        undefined_error = error
        undefined_error.insert(3, Spinach::StepNotDefinedException.new(anything))

        String.any_instance.expects(:red)

        @reporter.summarized_error(error)
      end
    end
  end

  describe '#full_error' do
    describe "when dealing with general errors" do
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

    describe "when it's a step not defined exception" do
      it "returns a suggestion" do
        @exception = Spinach::StepNotDefinedException.new(stub(name: "foo"))
        @error = [stub(name: 'My feature'),
          stub(name: 'A scenario'),
          stub(keyword: 'Given', name: 'foo'),
          @exception]
        output = @reporter.full_error(@error)
        output.must_include "step"
        output.must_include "foo"
      end
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
      it 'prints the error in red' do
        undefined_exception = Spinach::StepNotDefinedException.new(stub(name: 'some step'))

        String.any_instance.expects(:red)

        @reporter.report_exception(undefined_exception)
      end
    end
  end
end
