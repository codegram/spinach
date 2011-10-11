module Spinach
  class Generators::FeatureGenerator
    attr_reader :data

    def initialize(data)
      @data = data
    end

    def steps
      return @steps if @steps
      @steps = []
      if scenarios = data['elements']
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

    def name
      @data['name'].strip if @data['name']
    end

    def generate
      result = StringIO.new
      result.puts "Feature '#{Spinach::Support.escape name}' do"
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

    def filename
      Spinach::Support.underscore (
        Spinach::Support.camelize name
      ) + ".rb"
    end

    def path
      Spinach.config[:step_definitions_path]
    end

    def filename_with_path
      File.expand_path File.join(path, filename)
    end

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

    class FeatureGeneratorException < Exception; end;

  end
end
