require_relative '../test_helper'

describe Spinach::Config do
  subject do
    Spinach::Config.new
  end

 describe '#features_path' do
   it 'returns a default' do
     subject[:features_path].must_be_kind_of String
   end
   
   it 'can be overwritten' do
     subject[:features_path] = 'test'
     subject[:features_path].must_equal 'test'
   end
 end

  describe '#step_definitions_path' do
    it 'returns a default' do
      subject[:step_definitions_path].must_be_kind_of String
    end

    it 'can be overwritten' do
      subject[:step_definitions_path] = 'steps'
      subject[:step_definitions_path].must_equal 'steps'
    end
  end

  describe '#support_path' do
    it 'returns a default' do
      subject[:support_path].must_be_kind_of String
    end

    it 'can be overwritten' do
      subject[:support_path] = 'support'
      subject[:support_path].must_equal 'support'
    end
  end

  describe '#failure_exceptions' do
    it 'returns a default' do
      subject[:failure_exceptions].must_be_kind_of Array
    end

    it 'can be overwritten' do
      subject[:failure_exceptions] = [1, 2, 3]
      subject[:failure_exceptions].must_equal [1,2,3]
    end

    it 'allows adding elements' do
      subject[:failure_exceptions] << RuntimeError
      subject[:failure_exceptions].must_include RuntimeError
    end
  end
end
