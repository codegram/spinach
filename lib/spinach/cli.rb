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
      options

      if Spinach.config.generate
        Spinach::Generators.run(feature_files)
      elsif Spinach.config.audit
        Spinach::Auditor.new(feature_files).run
      else
        Spinach::Runner.new(feature_files).run
      end
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

    # Uses given args to list the feature files to run. It will find a single
    # feature, features in a folder and subfolders or every feature file in the
    # feature path.
    #
    # @return [Array]
    #   An array with the feature file names.
    #
    # @api public
    def feature_files
      files_to_run = []

      @args.each do |arg|
        if arg.match(/\.feature/)
          if File.exists? arg.gsub(/:\d*/, '')
            files_to_run << arg
          else
            fail! "#{arg} could not be found"
          end
        elsif File.directory?(arg)
          files_to_run << Dir.glob(File.join(arg, '**', '*.feature'))
        elsif arg != "{}"
          fail! "invalid argument - #{arg}"
        end
      end

      if !files_to_run.empty?
        files_to_run.flatten
      else
        Dir.glob(File.join(Spinach.config[:features_path], '**', '*.feature'))
      end
    end

    private

    # Parses the arguments into options.
    #
    # @return [Hash]
    #   A hash of options separated by its type.
    #
    # @api private
    def parse_options
      config = {}

      begin
        OptionParser.new do |opts|
          opts.on('-c', '--config_path PATH',
                  'Parse options from file (will get overriden by flags)') do |file|
            Spinach.config[:config_path] = file
          end

          opts.on('-b', '--backtrace',
                  'Show backtrace of errors') do |show_backtrace|
            config[:reporter_options] = {backtrace: show_backtrace}
          end

          opts.on('-t', '--tags TAG',
                  'Run all scenarios for given tags.') do |tag|
            config[:tags] ||= []
            tags = tag.delete('@').split(',')

            if (config[:tags] + tags).flatten.none? { |t| t =~ /wip$/ }
              tags.unshift '~wip'
            end

            config[:tags] << tags
          end

          opts.on('-g', '--generate',
                  'Auto-generate the feature steps files') do
            config[:generate] = true
          end

          opts.on_tail('--version', 'Show version') do
            puts Spinach::VERSION
            exit
          end

          opts.on('-f', '--features_path PATH',
                  'Path where your features will be searched for') do |path|
            config[:features_path] = path
          end

          opts.on('-r', '--reporter CLASS_NAMES',
                  'Formatter class names, separated by commas') do |class_names|
            names = class_names.split(',').map { |c| reporter_class(c) }
            config[:reporter_classes] = names
          end

          opts.on_tail('--fail-fast',
                       'Terminate the suite run on the first failure') do |class_name|
            config[:fail_fast] = true
          end

          opts.on('-a', '--audit',
                  "Audit steps instead of running them, outputting missing \
and obsolete steps") do
            config[:audit] = true
          end
        end.parse!(@args)

        Spinach.config.parse_from_file
        config.each{|k,v| Spinach.config[k] = v}
        if Spinach.config.tags.empty? ||
          Spinach.config.tags.flatten.none?{ |t| t =~ /wip$/ }
          Spinach.config.tags.unshift ['~wip']
        end
      rescue OptionParser::ParseError => exception
        puts exception.message.capitalize
        exit 1
      end
    end

    # exit test run with an optional message to the user
    def fail!(message=nil)
      puts message if message
      exit 1
    end

    # Builds the class name to use an output reporter.
    #
    # @param [String] klass
    #   The class name fo the reporter.
    #
    # @return [String]
    #   The full name of the reporter class.
    #
    # @example
    #   reporter_class('progress')
    #   # => Spinach::Reporter::Progress
    #
    # @api private
    def reporter_class(klass)
      "Spinach::Reporter::" + Spinach::Support.camelize(klass)
    end
  end
end
