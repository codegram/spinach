require_relative '../test_helper'

describe Spinach::Config do
  before do
    @config = Spinach::Config.new
  end
  describe '#step_definitions_path' do
    it 'returns a default' do
      (@config[:step_definitions_path].kind_of? String).must_equal true
    end

    it 'can be overwritten' do
      @config[:step_definitions_path] = 'steps'
      @config[:step_definitions_path].must_equal 'steps'
    end
  end

  describe '#support_path' do
    it 'returns a default' do
      (@config[:support_path].kind_of? String).must_equal true
    end

    it 'can be overwritten' do
      @config[:support_path] = 'support'
      @config[:support_path].must_equal 'support'
    end
  end

  describe '#failure_exceptions' do
    it 'returns a default' do
      @config[:failure_exceptions].kind_of?(Array).must_equal true
    end

    it 'can be overwritten' do
      @config[:failure_exceptions] = [1, 2, 3]
      @config[:failure_exceptions].must_equal [1,2,3]
    end

    it 'allows adding elements' do
      @config[:failure_exceptions] << RuntimeError
      @config[:failure_exceptions].must_include RuntimeError
    end
  end
end
