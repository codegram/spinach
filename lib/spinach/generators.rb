module Spinach
  # Spinach generators are a set of utils that auto-generates example features
  # given some parsed feature data.
  #
  module Generators
    # generates steps for features
    # @files [Array]
    #   filenames to evaluate for step generation
    def self.run(files)
      files.each do |file|
        feature = Parser.open_file(file).parse

        begin
          FeatureGenerator.new(feature).store
        rescue FeatureGeneratorException => e
          $stderr.puts e
        end
      end
    end
  end
end

require_relative 'generators/feature_generator'
require_relative 'generators/step_generator'
