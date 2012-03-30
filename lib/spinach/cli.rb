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
        Dir.glob(File.join Spinach.config[:features_path], '**', '*.feature')
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
      config = {}

      begin
        OptionParser.new do |opts|
          opts.on('-c', '--config_path PATH',
                  'Parse options from file (will get overriden by flags)') do |file|
            Spinach.config[:config_path] = file
          end

          opts.on('-b', '--backtrace',
                  'Show backtrace of errors') do |show_backtrace|
            reporter_options[:backtrace] = show_backtrace
          end

          opts.on('-t', '--tags TAG',
                  'Run all scenarios for given tag.') do |tag|
            config[:tag] ||= []
            config[:tag] << tag.delete('@').split(',')
          end

          opts.on('-g', '--generate',
                  'Auto-generate the feature steps files') do
            Spinach::Generators.bind
          end

          opts.on_tail('--version', 'Show version') do
            puts Spinach::VERSION
            exit
          end

          opts.on('-f', '--features_path PATH',
                  'Path where your features will be searched for') do |path|
            config[:features_path] = path
          end
        end.parse!(@args)

        Spinach.config.parse_from_file
        config.each{|k,v| Spinach.config[k] = v}
      rescue OptionParser::ParseError => exception
        puts exception.message.capitalize
        exit 1
      end

      {reporter: reporter_options}
    end
  end
end
