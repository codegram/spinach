require "yaml"

module Spinach
  # Accesses spinach config. Allows you to configure several runtime options,
  # like the step definitions path.
  #
  # @return [Config]
  #   The config object
  #
  # @example
  #   Spinach.config[:step_definitions_path]
  #     # => 'features/steps'
  #   Spinach.config[:step_definitions_path] = 'integration/steps'
  #     # => 'integration/steps'
  #
  # @api public
  def self.config
    @config ||= Config.new
  end

  # The config object holds all the runtime configurations needed for spinach
  # to run.
  #
  class Config
    attr_writer :features_path,
                :step_definitions_path,
                :default_reporter,
                :support_path,
                :failure_exceptions,
                :config_path,
                :tags,
                :generate,
                :save_and_open_page_on_failure,
                :reporter_classes,
                :reporter_options,
                :fail_fast,
                :audit


    # The "features path" holds the place where your features will be
    # searched for. Defaults to 'features'
    #
    # @return [String]
    #    The features path.
    #
    # @api public
    def features_path
      @features_path || 'features'
    end

    # The "reporter classes" holds an array of reporter class name
    # Default to ["Spinach::Reporter::Stdout"]
    #
    # @return [Array<reporter object>]
    #    The reporters that respond to specific messages.
    #
    # @api public
    def reporter_classes
      @reporter_classes || ["Spinach::Reporter::Stdout"]
    end

    # The "reporter_options" holds the options passed to reporter_classes
    #
    # @api public
    def reporter_options
      @reporter_options || {}
    end

    # The "step definitions path" holds the place where your feature step
    # classes will be searched for. Defaults to '#{features_path}/steps'
    #
    # @return [String]
    #   The step definitions path.
    #
    # @api public
    def step_definitions_path
      @step_definitions_path || "#{self.features_path}/steps"
    end

    # The "support path" helds the place where you can put your configuration
    # files. Defaults to '#{features_path}/support'
    #
    # @return [String]
    #   The support file path.
    #
    # @api public
    def support_path
      @support_path || "#{self.features_path}/support"
    end

    def generate
      @generate || false
    end

    # Allows you to read the config object using a hash-like syntax.
    #
    # @param [String] attribute
    #   The attribute to fetch.
    #
    # @example
    #   Spinach.config[:step_definitions_path]
    #   # => 'features/steps'
    #
    # @api public
    def [](attribute)
      self.send(attribute)
    end

    # Allows you to set config properties using a hash-like syntax.
    #
    # @param [#to_s] attribute
    #   The attribute to set.
    #
    # @param [Object] value
    #   The value to set the attribute to.
    #
    # @example
    #   Spinach.config[:step_definitions_path] = 'integration/steps'
    #     # => 'integration/steps'
    #
    # @api public
    def []=(attribute, value)
      self.send("#{attribute}=", value)
    end

    # The failure exceptions return an array of exceptions to be captured and
    # considered as failures (as opposite of errors)
    #
    # @return [Array<Exception>]
    #
    # @api public
    def failure_exceptions
      @failure_exceptions ||= []
    end

    # The "fail_fast" determines if the suite run should exit
    # when encountering a failure/error
    #
    # @return [true/false]
    #    The fail_fast flag.
    #
    # @api public
    def fail_fast
      @fail_fast
    end

    # "audit" enables step auditing mode
    #
    # @return [true/false]
    #    The audit flag.
    #
    # @api public
    def audit
      @audit || false
    end

    # It allows you to set a config file to parse for all the other options to be set
    #
    # @return [String]
    #   The config file name
    #
    def config_path
      @config_path ||= 'config/spinach.yml'
    end

    # When using capybara, it automatically shows the current page when there's
    # a failure
    #
    def save_and_open_page_on_failure
      @save_and_open_page_on_failure ||= false
    end

    # Tags to tell Spinach that you only want to run scenarios that have (or
    # don't have) certain tags.
    #
    # @return [Array]
    #   The tags.
    #
    def tags
      @tags ||= []
    end

    # Parse options from the config file
    #
    # @return [Boolean]
    #   If the config was parsed from the file
    #
    def parse_from_file
      parsed_opts = YAML.load_file(config_path)
      parsed_opts.delete_if{|k| k.to_s == 'config_path'}
      parsed_opts.each_pair{|k,v| self[k] = v}
      true
    rescue Errno::ENOENT
      false
    end
  end
end
