module Spinach
  class Parser
    class Visitor
      attr_reader :feature

      # @param [Feature] feature
      #   The feature to populate,
      #
      # @api public
      def initialize(feature)
        @feature = feature
      end

      # @param [Gherkin::AST::Feature] ast
      #   The AST root node to visit.
      #
      # @api public
      def visit(ast)
        ast.accept self
      end

      # Sets the feature name and iterates over the feature scenarios.
      #
      # @param [Gherkin::AST::Feature] feature
      #   The feature to visit.
      #
      # @api public
      def visit_Feature(node)
        @feature.name = node.name
        node.scenarios.each { |scenario| scenario.accept(self) }
      end

      # Sets the scenario name and iterates over the steps.
      #
      # @param [Gherkin::AST::Feature] node
      #   The scenario to visit.
      #
      # @api public
      def visit_Scenario(node)
        @current_scenario      = Scenario.new
        @current_scenario.name = node.name

        node.tags.each  { |tag|  tag.accept(self)  }
        node.steps.each { |step| step.accept(self) }

        @feature.scenarios << @current_scenario
      end
    end
  end
end
