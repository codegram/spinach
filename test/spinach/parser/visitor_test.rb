require 'test_helper'

module Spinach
  class Parser
    describe Visitor do
      let(:feature) { Feature.new }
      let(:visitor) { Visitor.new(feature) }

      it 'initializes with a Feature' do
        visitor.feature.must_equal feature
      end

      describe '#visit' do
        it 'makes ast accept self' do
          ast = stub('AST')
          ast.expects(:accept).with(visitor)

          visitor.visit(ast)
        end
      end

      describe '#visit_Feature' do
        before do
          @scenarios = [stub_everything, stub_everything, stub_everything]
          @node  = stub(scenarios: @scenarios, name: 'Go shopping')
        end

        it 'sets the name' do
          visitor.visit_Feature(@node)
          feature.name.must_equal 'Go shopping'
        end

        it 'iterates over its children' do
          @scenarios.each do |scenario|
            scenario.expects(:accept).with visitor
          end

          visitor.visit_Feature(@node)
        end
      end

      describe '#visit_Scenario' do
        before do
          @steps = [stub_everything, stub_everything, stub_everything]
          @tags  = [stub_everything, stub_everything, stub_everything]
          @node  = stub(tags: @tags, steps: @steps, name: 'Go shopping on Saturday morning')
        end

        it 'adds the scenario to the feature' do
          visitor.visit_Scenario(@node)
          feature.scenarios.length.must_equal 1
        end

        it 'sets the name' do
          visitor.visit_Scenario(@node)
          feature.scenarios.first.name.must_equal 'Go shopping on Saturday morning'
        end

        it 'sets the tags' do
          @tags.each do |step|
            step.expects(:accept).with visitor
          end
          visitor.visit_Scenario(@node)
        end

        it 'iterates over its children' do
          @steps.each do |step|
            step.expects(:accept).with visitor
          end
          visitor.visit_Scenario(@node)
        end
      end
    end
  end
end
