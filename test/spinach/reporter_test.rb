# encoding: utf-8
require_relative '../test_helper'

describe Spinach::Reporter do
  describe 'abstract methods' do
    let(:reporter) { Spinach::Reporter.new }

    %w{feature scenario}.each do |abstract_method|
      describe '#{abstract_method}' do
        it 'raises an error' do
          proc {
            reporter.send(abstract_method, 'arbitrary name')
          }.must_raise RuntimeError
        end
      end
    end

    describe '#step' do
      it 'raises an error' do
        proc { @reporter.step(stub, :success) }.must_raise RuntimeError
      end
    end

    describe '#end' do
      it 'raises an error' do
        proc { reporter.end(true) }.must_raise RuntimeError
      end
    end
  end
end
