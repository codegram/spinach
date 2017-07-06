module Spinach
  # Runner gets the parsed data from the feature and performs the actual calls
  # to the feature classes.
  #
  class Runner

    # The feature files to run
    attr_reader :filenames

    # The default path where the steps are located
    attr_reader :step_definitions_path

    # The default path where the support files are located
    attr_reader :support_path

    # Initializes the runner with a parsed feature
    #
    # @param [Array<String>] filenames
    #   A list of feature filenames to run
    #
    # @param [Hash] options
    #
    # @option options [String] :step_definitions_path
    #   The path in which step definitions are found.
    #
    # @option options [String] :support_path
    #   The path with the support ruby files.
    #
    # @api public
    def initialize(filenames, options = {})
      @filenames = filenames

      @step_definitions_path = options.delete(:step_definitions_path ) ||
        Spinach.config.step_definitions_path

      @support_path = options.delete(:support_path ) ||
        Spinach.config.support_path
    end

    # Inits the reporter with a default one.
    #
    # @api public
    def init_reporters
      Spinach.config[:reporter_classes].each do |reporter_class|
        reporter = Support.constantize(reporter_class).new(Spinach.config.reporter_options)
        reporter.bind
      end
    end

    # Runs this runner and outputs the results in a colorful manner.
    #
    # @return [true, false]
    #   Whether the run was succesful.
    #
    # @api public
    def run
      require_dependencies
      require_frameworks
      init_reporters

      features = filenames.map do |filename|
        file, *lines = filename.split(":") # little more complex than just a "filename"

        # FIXME Feature should be instantiated directly, not through an unrelated class method
        feature          = Parser.open_file(file).parse
        feature.filename = file

        feature.lines_to_run = lines if lines.any?

        feature
      end

      suite_passed = true

      Spinach.hooks.run_before_run

      features.each do |feature|
        feature_passed = FeatureRunner.new(feature).run
        suite_passed &&= feature_passed

        break if fail_fast? && !feature_passed
      end

      Spinach.hooks.run_after_run(suite_passed)

      suite_passed
    end

    # Loads support files and step definitions, ensuring that env.rb is loaded
    # first.
    #
    # @api public
    def require_dependencies
      required_files.each do |file|
        require file
      end
    end

    # Requires the test framework support
    #
    def require_frameworks
      require_relative 'frameworks'
    end

    # Returns an array of files to be required. Sorted by the most nested files first, then alphabetically.
    # @return [Array<String>] files
    #   The step definition files.
    #
    # @api public
    def step_definition_files
      Dir.glob(
        File.expand_path File.join(step_definitions_path, '**', '*.rb')
      ).sort{|a,b| [b.count(File::SEPARATOR), a] <=> [a.count(File::SEPARATOR), b]}
    end

    # Returns an array of support files inside the support_path. Will
    # put "env.rb" in the beginning
    #
    # @return [Array<String>] files
    #   The support files.
    #
    # @api public
    def support_files
      support_files = Dir.glob(
        File.expand_path File.join(support_path, '**', '*.rb')
      )
      environment_file = support_files.find do |f|
        f.include?(File.join support_path, 'env.rb')
      end
      support_files.unshift(environment_file).compact.uniq
    end

    # @return [Array<String>] files
    #   All support files with env.rb ordered first, followed by the step
    #   definitions.
    #
    # @api public
    def required_files
      support_files + step_definition_files
    end

    private

    def fail_fast?
      Spinach.config.fail_fast
    end
  end
end

require_relative 'runner/feature_runner'
require_relative 'runner/scenario_runner'
