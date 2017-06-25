require_relative '../../test_helper'

module Spinach
  class Parser
    describe Visitor do
      let(:feature) { Feature.new }
      let(:visitor) { Visitor.new }

      describe '#visit' do
        it 'makes ast accept self' do
          ast = stub('AST')
          ast.expects(:accept).with(visitor)

          visitor.visit(ast)
        end

        it 'returns the feature' do
          ast = stub_everything
          visitor.instance_variable_set(:@feature, feature)
          visitor.visit(ast).must_equal feature
        end
      end

      describe '#visit_Feature' do
        before do
          @background = stub_everything
          @tags  = [stub_everything, stub_everything, stub_everything]
          @scenarios = [stub_everything, stub_everything, stub_everything]
          @node  = stub(
            scenarios: @scenarios,
            name: 'Go shopping',
            description: ['some non-interpreted info','from the description'],
            background: @background,
            tags: @tags
          )
        end

        it 'sets the name' do
          visitor.visit_Feature(@node)
          visitor.feature.name.must_equal 'Go shopping'
        end

        it 'sets the description' do
          visitor.visit_Feature(@node)
          visitor.feature.description.must_equal ['some non-interpreted info','from the description']
        end

        it 'sets the tags' do
          @tags.each do |step|
            step.expects(:accept).with visitor
          end
          visitor.visit_Feature(@node)
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
          @steps = [
            stub_everything(line: 4),
            stub_everything(line: 5),
            stub_everything(line: 6)
          ]
          @tags  = [stub_everything, stub_everything, stub_everything]
          @node  = stub(
            tags:  @tags,
            steps: @steps,
            name:  'Go shopping on Saturday morning',
            line: 3
          )
        end

        it 'adds the scenario to the feature' do
          visitor.visit_Scenario(@node)
          visitor.feature.scenarios.length.must_equal 1
        end

        it 'sets the name' do
          visitor.visit_Scenario(@node)
          visitor.feature.scenarios.first.name.must_equal 'Go shopping on Saturday morning'
        end

        it 'sets the lines' do
          visitor.visit_Scenario(@node)
          visitor.feature.scenarios.first.lines.must_equal (3..6).to_a
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

      describe '#visit_Background' do
        before do
          @steps = [stub_everything, stub_everything, stub_everything]
          @node  = stub(
            steps: @steps,
            line: 3
          )
        end

        it 'adds the background to the feature' do
          visitor.visit_Background(@node)
          visitor.feature.background.must_be_kind_of Background
        end

        it 'sets the line' do
          visitor.visit_Background(@node)
          visitor.feature.background.line.must_equal 3
        end

        it 'iterates over its children' do
          @steps.each do |step|
            step.expects(:accept).with visitor
          end
          visitor.visit_Background(@node)
        end

        it 'visits the background' do
          visitor.visit_Background(@node)
        end
      end

      describe '#visit_Tag' do
        it 'adds the tag to the current scenario' do
          tags     = ['tag1', 'tag2', 'tag3']
          scenario = stub(tags: tags)
          visitor.instance_variable_set(:@current_scenario, scenario)
          visitor.instance_variable_set(:@current_tag_set, scenario)

          visitor.visit_Tag(stub(name: 'tag4'))
          scenario.tags.must_equal ['tag1', 'tag2', 'tag3', 'tag4']
        end
      end

      describe '#visit_Step' do
        before do
          @node  = stub(name: 'Baz', line: 3, keyword: 'Given')
          @steps = [stub(name: 'Foo'), stub(name: 'Bar')]
        end

        it 'adds the step to the step set' do
          step_set = stub(steps: @steps)
          visitor.instance_variable_set(:@current_step_set, step_set)

          visitor.visit_Step(@node)
          step_set.steps.length.must_equal 3
        end

        it 'sets the name' do
          step_set = stub(steps: [])
          visitor.instance_variable_set(:@current_step_set, step_set)

          visitor.visit_Step(@node)

          step_set.steps.first.name.must_equal 'Baz'
        end

        it 'sets the keyword' do
          step_set = stub(steps: [])
          visitor.instance_variable_set(:@current_step_set, step_set)

          visitor.visit_Step(@node)

          step_set.steps.first.keyword.must_equal 'Given'
        end

        it 'sets the line' do
          step_set = stub(steps: [])
          visitor.instance_variable_set(:@current_step_set, step_set)

          visitor.visit_Step(@node)

          step_set.steps.first.line.must_equal 3
        end
      end
    end
  end
end
