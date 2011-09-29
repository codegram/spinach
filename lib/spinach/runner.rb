module Spinach
  # Spinach's runner gets the parsed data from the feature and performs the
  # actual calls to the feature classes.
  #
  class Runner

    # Initializes the runner with a parsed feature
    #
    # @param [Array<String>] filenames
    #   an array of feature filenames to run
    #
    # @param [Hash] options
    #
    # @option options [String] :step_definitions_path
    #   The path in which step definitions are found
    #
    # @option options [String] :support_path
    #   The path with the support ruby files
    #
    def initialize(filenames, options = {})
      @filenames = filenames

      @step_definitions_path = options.delete(:step_definitions_path ) ||
        Spinach.config.step_definitions_path

      @support_path = options.delete(:support_path ) ||
        Spinach.config.support_path

    end

    def reporter
      @reporter ||= Spinach::config.default_reporter
    end

    attr_reader :filenames

    # The default path where the steps are located
    attr_reader :step_definitions_path

    # The default path where the support files are located
    attr_reader :support_path

    # Runs this runner and outputs the results in a colorful manner.
    #
    def run
      require_dependencies

      filenames.each do |filename|
        Feature.new(filename, reporter).run
      end
      reporter.end

    end

    # Requires step definitions and support files
    #
    def require_dependencies
      (support_files + step_definition_files).each do |file|
        require file
      end
    end

    # List of step definition files
    #
    # @return [Array<String>] files
    #
    def step_definition_files
      Dir.glob(
        File.expand_path File.join(step_definitions_path, '**', '*.rb')
      )
    end

    # List of support files
    #
    # @return [Array<String>] files
    #
    def support_files
      Dir.glob(
        File.expand_path File.join(support_path, '**', '*.rb')
      )
    end

  end
end

require_relative 'runner/feature'
require_relative 'runner/scenario'
