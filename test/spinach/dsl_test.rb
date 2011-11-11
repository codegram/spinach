require_relative '../test_helper'

describe Spinach::DSL do
  before do
    @feature = Class.new do
      include Spinach::DSL
    end
  end

  describe 'class methods' do
    describe '#When' do
      it 'defines a method with the step name' do
        step_executed = false
        @feature.When('I say goodbye') do
          step_executed = true
        end

        @feature.new.execute(stub(name: 'I say goodbye'))
        step_executed.must_equal true
      end
    end

    describe '#When, #Then, #And, #But' do
      it 'are #Given aliases' do
        %w{When Then And But}.each do |method|
          @feature.must_respond_to method
        end
      end
    end

    describe '#feature' do
      it 'sets the name for this feature' do
        @feature.feature('User salutes')
        @feature.feature_name.must_equal 'User salutes'
      end
    end

    describe "#name" do
      it "responds with a feature's name" do
        @feature.feature("A cool feature")
        @feature.new.name.must_equal "A cool feature"
      end
    end

    describe '#step_location_for' do
      it 'returns step source location' do
        @feature.When('I say goodbye') do
          'You say hello'
        end

        @feature.new.step_location_for('I say goodbye').first.must_include '/dsl_test.rb'
        @feature.new.step_location_for('I say goodbye').last.must_be_kind_of Fixnum
      end
    end
  end
end
