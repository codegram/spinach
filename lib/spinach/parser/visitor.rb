module Spinach
  class Parser
    # The Spinach Visitor traverses the output AST from the Gherkin parser and
    # populates its Feature with all the scenarios, tags, steps, etc.
    #
    # @example
    #
    #   ast     = Gherkin.parse(File.read('some.feature')
    #   visitor = Spinach::Parser::Visitor.new
    #   feature = visitor.visit(ast)
    #
    class Visitor
      attr_reader :feature

      # @param [Feature] feature
      #   The feature to populate,
      #
      # @api public
      def initialize
        @feature = Feature.new
      end

      # @param [Gherkin::AST::Feature] ast
      #   The AST root node to visit.
      #
      # @api public
      def visit(ast)
        ast.accept self
        @feature
      end

      # Sets the feature name and iterates over the feature scenarios.
      #
      # @param [Gherkin::AST::Feature] feature
      #   The feature to visit.
      #
      # @api public
      def visit_Feature(node)
        @feature.name = node.name
        node.background.accept(self) if node.background

        @current_tag_set = @feature
        node.tags.each  { |tag|  tag.accept(self)  }
        @current_tag_set = nil

        node.scenarios.each { |scenario| scenario.accept(self) }
      end

      # Iterates over the steps.
      #
      # @param [Gherkin::AST::Scenario] node
      #   The scenario to visit.
      #
      # @api public
      def visit_Background(node)
        background = Background.new(@feature)
        background.line = node.line

        @current_step_set = background
        node.steps.each { |step| step.accept(self) }
        @current_step_set = nil

        @feature.background = background
      end

      # Sets the scenario name and iterates over the steps.
      #
      # @param [Gherkin::AST::Scenario] node
      #   The scenario to visit.
      #
      # @api public
      def visit_Scenario(node)
        scenario      = Scenario.new(@feature)
        scenario.name = node.name
        scenario.line = node.line

        @current_tag_set = scenario
        node.tags.each  { |tag|  tag.accept(self)  }
        @current_tag_set = nil

        @current_step_set = scenario
        node.steps.each { |step| step.accept(self) }
        @current_step_set = nil

        @feature.scenarios << scenario
      end

      # Adds the tag to the current scenario.
      #
      # @param [Gherkin::AST::Tag] node
      #   The tag to add.
      #
      # @api public
      def visit_Tag(node)
        @current_tag_set.tags << node.name
      end

      # Adds the step to the current scenario.
      #
      # @param [Gherkin::AST::Step] step
      #   The step to add.
      #
      # @api public
      def visit_Step(node)
        step = Step.new(@current_scenario)
        step.name    = node.name
        step.line    = node.line
        step.keyword = node.keyword

        @current_step_set.steps << step
      end
    end
  end
end
