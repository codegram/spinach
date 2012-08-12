require_relative '../test_helper'

describe Spinach::DSL do
  before do
    @feature = Class.new do
      include Spinach::DSL
    end
  end

  describe 'class methods' do
    describe '#step' do
      it 'defines a method with the step name' do
        step_executed = false
        @feature.step('I say goodbye') do
          step_executed = true
        end

        @feature.new.execute(stub(name: 'I say goodbye'))
        step_executed.must_equal true
      end
    end

    describe '#Give, #When, #Then, #And, #But' do
      it 'are #step aliases' do
        %w{Given When Then And But}.each do |method|
          @feature.must_respond_to method
        end
      end
    end

    describe "#after" do
      let(:super_class) {
        Class.new do
          attr_reader :var1
          def after_each
            @var1 = 30
            @var2 = 60
          end
        end
      }

      let(:feature) {
        Class.new(super_class) do
          attr_accessor :var2
          include Spinach::DSL
          after do
            self.var2 = 40
          end
        end
      }

      let(:object) { feature.new }
      
      it "defines after_each method and calls the super first" do
        object.after_each
        object.var1.must_equal 30
      end
      
      it "defines after_each method and runs the block second" do
        object.after_each
        object.var2.must_equal 40
      end

      describe "deep inheritance" do
        let(:sub_feature) {
          Class.new(feature) do
            include Spinach::DSL
            attr_reader :var3

            after do
              @var3 = 15
            end
          end
        }

        let(:sub_object) { sub_feature.new }

        it "works with the 3rd layer of inheritance" do
          sub_object.after_each
          sub_object.var2.must_equal 40
        end
      end
    end

    describe "#before" do
      let(:super_class) {
        Class.new do
          attr_reader :var1
          def before_each
            @var1 = 30
            @var2 = 60
          end
        end
      }

      let(:feature) {
        Class.new(super_class) do
          attr_accessor :var2
          include Spinach::DSL
          before do
            self.var2 = 40
          end
        end
      }

      let(:object) { feature.new }
      
      it "defines before_each method and calls the super first" do
        object.before_each
        object.var1.must_equal 30
      end
      
      it "defines before_each method and runs the block second" do
        object.before_each
        object.var2.must_equal 40
      end

      describe "deep inheritance" do
        let(:sub_feature) {
          Class.new(feature) do
            include Spinach::DSL
            attr_reader :var3

            before do
              @var3 = 15
            end
          end
        }

        let(:sub_object) { sub_feature.new }

        it "works with the 3rd layer of inheritance" do
          sub_object.before_each
          sub_object.var2.must_equal 40
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
