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
    attr_writer :step_definitions_path, :default_reporter, :support_path

    # The "step definitions path" holds the place where your feature classes
    # will be searched for. Defaults to 'features/steps'
    #
    # @return [String]
    #   The step definitions path.
    #
    # @api public
    def step_definitions_path
      @step_definitions_path || 'features/steps'
    end

    # The "support path" helds the place where you can put your configuration
    # files.
    #
    # @return [String]
    #   The support file path.
    #
    # @api public
    def support_path
      @support_path || 'features/support'
    end

    # The default reporter is the reporter spinach will use if there's no other
    # specified. Defaults to Spinach::Reporter::Stdout, which will print all
    # output to the standard output
    #
    def default_reporter
      @default_reporter || Spinach::Reporter::Stdout.new
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
  end
end
