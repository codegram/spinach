require 'optparse'

module Spinach
  # The cli is a class responsible of handling all the command line interface
  # logic.
  #
  class Cli
    # @param [Array<String>] arguments
    #   The command line arguments
    #
    # @api public
    def initialize(args = ARGV)
      @args = args
    end

    # Runs all the features.
    #
    # @return [true, false]
    #   The exit status - true for success, false for failure.
    #
    # @api public
    def run
      parse_options
      features = if @args.any?
        @args
      else
        Dir.glob(File.join 'features', '**', '*.feature')
      end
      Spinach::Runner.new(features).run
    end

    # Inits the reporter with a default one.
    #
    # @api public
    def init_reporter
      reporter =
        Spinach::Reporter::Stdout.new(options[:reporter])
      reporter.bind
    end

    # @return [Hash]
    #   A hash of options separated by its type.
    #
    # @example
    #   Cli.new.options
    #   # => { reporter: { backtrace: true } }
    #
    # @api public
    def options
      @options ||= parse_options
    end

    private

    # Parses the arguments into options.
    #
    # @return [Hash]
    #   A hash of options separated by its type.
    #
    # @api private
    def parse_options
      reporter_options = {}
      reporter_options[:backtrace] = false

      OptionParser.new do |opts|
        opts.on('-b', '--backtrace', 'Show backtrace of errors') do |v|
          reporter_options[:backtrace] = v
        end
        opts.on('-g', '--generate', 'Auto-generate the feeature steps files') do |v|
          Spinach::Generators.bind
        end
        opts.on_tail('--version', 'Show version') do
          puts Spinach::VERSION
          exit
        end
      end.parse!(@args)

      {reporter: reporter_options}
    end
  end
end
