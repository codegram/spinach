# encoding: utf-8

require_relative '../../test_helper'

describe Spinach::Reporter::FailureFile do
  let(:feature) { stub_everything(filename: 'features/test.feature') }
  let(:scenario) { stub_everything(lines: [1,2]) }

  describe '#initialize' do
    it 'generates a distinctive output filename if none is provided' do
      @reporter = Spinach::Reporter::FailureFile.new
      @reporter.filename.wont_be_nil
      @reporter.filename.must_be_kind_of String
    end

    it 'uses a provided output filename option' do
      @reporter = Spinach::Reporter::FailureFile.new(failure_filename: 'foo')
      @reporter.filename.must_equal 'foo'
    end

    it 'uses a provided output filename environment variable' do
      ENV['SPINACH_FAILURE_FILE'] = 'asdf'
      @reporter = Spinach::Reporter::FailureFile.new
      @reporter.filename.must_equal 'asdf'
    end

    it 'initializes the array of failing scenarios' do
      @reporter = Spinach::Reporter::FailureFile.new
      @reporter.failing_scenarios.wont_be_nil
      @reporter.failing_scenarios.must_be_kind_of Array
      @reporter.failing_scenarios.must_be_empty
    end

    after do
      ENV.delete('SPINACH_FAILURE_FILE')
    end
  end

  describe 'hooks' do
    before do
      @reporter = Spinach::Reporter::FailureFile.new(failure_filename: "tmp/test-failures_#{Time.now.strftime('%F_%H-%M-%S-%L')}.txt")
      @reporter.set_current_feature(feature)
      @reporter.set_current_scenario(scenario)
    end

    describe '#on_failed_step' do
      it 'collects the feature and line number for outputting later' do
        @reporter.failing_scenarios.must_be_empty
        @reporter.on_failed_step(anything)
        @reporter.failing_scenarios.must_include "#{feature.filename}:#{scenario.lines[0]}"
      end
    end

    describe '#on_error_step' do
      it 'collects the feature and line number for outputting later' do
        @reporter.failing_scenarios.must_be_empty
        @reporter.on_error_step(anything)      
        @reporter.failing_scenarios.must_include "#{feature.filename}:#{scenario.lines[0]}"
      end
    end

    describe '#after_run' do
      describe 'when the run has succeeded' do
        it 'no failure file is created' do
          @reporter.after_run(true)
          refute File.exist?(@reporter.filename), 'Output file should not exist when run is successful'
        end
      end

      describe 'when the run has failed' do
        it 'failure file is created and includes expected output' do
          @reporter.on_failed_step(anything)
          @reporter.after_run(false)
          assert File.exist?(@reporter.filename)
          f = File.open(@reporter.filename)
          f.read.must_equal "#{feature.filename}:#{scenario.lines[0]}"
          f.close
          File.unlink(@reporter.filename)
        end
      end
    end
  end

end