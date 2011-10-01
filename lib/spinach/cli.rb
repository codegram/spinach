require 'optparse'

module Spinach
  # The cli is a class responsible of handling all the command line interface
  # logic
  #
  class Cli
    # @param [Array<String>] arguments
    #   the command line arguments
    def initialize(args = ARGV)
      @args = args
    end

    # Runs all the feature
    #
    # @return [Boolean]
    #   the exit status - true for success, false for failure
    def run
      init_reporter
      parse_options
      features = if @args.any?
        @args
      else
        Dir.glob(File.join 'features', '**', '*.feature')
      end
      Spinach::Runner.new(features).run
    end

    # Inits the reporter with a default one
    def init_reporter
      Spinach.config.default_reporter =
        Spinach::Reporter::Stdout.new(options[:reporter])
    end

    # Returns a hash of options, separated by its type:
    #
    # @example
    #   {
    #     reporter: { backtrace: true }
    #   }
    #
    # @return [Hash]
    def options
      @options ||= parse_options
    end

  private

    def parse_options
      reporter_options = {}
      reporter_options[:backtrace] = false

      OptionParser.new do |opts|
        opts.on('-b', '--backtrace', "Show backtrace of errors") do |v|
          reporter_options[:backtrace] = v
        end
        opts.on_tail('--version', "Show version") do
          puts Spinach::VERSION
          exit
        end
      end.parse!(@args)
      {reporter: reporter_options}
    end


  end
end
