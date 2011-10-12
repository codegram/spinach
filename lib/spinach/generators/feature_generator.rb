module Spinach
  module Generators
    # A feature generator generates and/or writes an example feature steps class
    # given the parsed feture data
    class FeatureGenerator

      # @param [Hash] data
      #   the parsed feature data returned from the {Parser}
      def initialize(data)
        @data = data
      end

      # @return [Array<Hash>]
      #   an array of unique steps found in this scenario, avoiding name
      #   repetition
      def steps
        return @steps if @steps
        @steps = []
        if scenarios = @data['elements']
          scenarios.each do  |scenario|
            if scenario_steps = scenario['steps']
              scenario_steps.each do |step|
                unless @steps.any?{|s| s['name'] == step['name']}
                  @steps << {
                    'keyword' => step['keyword'].strip,
                    'name' => step['name'].strip
                  }
                end
              end
            end
          end
        end
        @steps
      end

      # @return [String]
      #   this feature's name
      def name
        @data['name'].strip if @data['name']
      end

      # @return [String]
      #   an example feature steps definition
      def generate
        result = StringIO.new
        result.puts "class #{Spinach::Support.camelize name} < Spinach::FeatureSteps"
        result.puts "  feature \'#{Spinach::Support.escape_single_commas name}\'\n"
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
        Spinach::Support.underscore (
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
          raise FeatureGeneratorException.new("File already exists")
        else
          FileUtils.mkdir_p path
          File.open(filename_with_path, 'w') do |file|
            file.write(generate)
          end
        end
      end

    end

    class FeatureGeneratorException < Exception; end;

  end
end
