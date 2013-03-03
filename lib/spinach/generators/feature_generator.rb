require "fileutils"

module Spinach
  module Generators
    # A feature generator generates and/or writes an example feature steps class
    # given the parsed feture data
    class FeatureGenerator

      attr_reader :feature

      # @param [Feature] feature
      #   The feature returned from the {Parser}
      def initialize(feature)
        @feature = feature
      end

      # @return [Array<Hash>]
      #   an array of unique steps found in this feature, avoiding name
      #   repetition
      def steps
        scenario_steps   = @feature.scenarios.map(&:steps).flatten
        background_steps = @feature.background_steps

        (scenario_steps + background_steps).uniq(&:name)
      end

      # @return [String]
      #   this feature's name
      def name
        @feature.name
      end

      # @return [String]
      #   an example feature steps definition
      def generate
        result = StringIO.new
        result.puts "class #{Spinach::Support.scoped_camelize name} < Spinach::FeatureSteps"
        generated_steps = steps.map do |step|
          step_generator = Generators::StepGenerator.new(step)
          step_generator.generate.split("\n").map do |line|
            "  #{line}"
          end.join("\n")
        end
        result.puts generated_steps.join("\n\n")
        result.puts "end"
        result.string
      end

      # @return [String]
      #   an example filename for this feature steps
      def filename
        Spinach::Support.underscore(
          Spinach::Support.camelize name
        ) + ".rb"
      end

      # @return [String]
      #   the path where this feature steps may be saved
      def path
        Spinach.config[:step_definitions_path]
      end

      # @return [String]
      #   the expanded path where this feature steps may be saved
      def filename_with_path
        File.expand_path File.join(path, filename)
      end

      # Stores the example feature steps definition into an expected path
      #
      def store
        if File.exists?(filename_with_path)
          raise FeatureGeneratorException.new("File #{filename_with_path} already exists.")
        else
          FileUtils.mkdir_p path
          File.open(filename_with_path, 'w') do |file|
            file.write(generate)
            puts "Generating #{File.basename(filename_with_path)}"
          end
        end
      end

    end

    class FeatureGeneratorException < Exception; end;
  end
end
