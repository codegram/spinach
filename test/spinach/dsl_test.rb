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
        @feature.When('I say goodbye') do
          'You say hello'
        end

        @feature.new.execute_step('I say goodbye').must_equal 'You say hello'
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
  end
end
