require 'optparse'

module Spinach
  class Cli
    def initialize(args = ARGV)
      @args = args
    end

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

    def init_reporter
      Spinach.config.default_reporter =
        Spinach::Reporter::Stdout.new(options[:reporter])
    end

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

    def options
      @options ||= parse_options
    end

  end
end
