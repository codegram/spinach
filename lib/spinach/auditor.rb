require 'set'

module Spinach
  # The auditor audits steps and determines if any are missing or obsolete.
  #
  # It is a subclass of Runner because it uses many of the Runner's features
  # when auditing.
  #
  class Auditor < Runner
    attr_accessor :unused_steps, :used_steps

    def initialize(filenames)
      super(filenames)
      @unused_steps = {}
      @used_steps = Set.new
    end

    # audits features
    # @files [Array]
    #   filenames to audit
    def run
      require_dependencies

      # Find any missing steps in each file, and keep track of unused steps
      clean = true
      filenames.each do |file|
        result = audit_file(file)
        clean &&= result # set to false if any result is false
      end

      # At the end, report any unused steps
      report_unused_steps

      # If the audit was clean, make sure the user knows
      puts "\nAudit clean - no missing steps.".colorize(:light_green) if clean

      true
    end

    private

    def audit_file(file)
      puts "\nAuditing: ".colorize(:magenta) + file.colorize(:light_magenta)

      # Find the feature definition and its associated step defs class
      feature, step_defs_class = get_feature_and_defs(file)
      return step_file_missing if step_defs_class.nil?
      step_defs = step_defs_class.new
      unused_step_names = step_names_for_class(step_defs_class)

      missing_steps = {}

      feature.each_step do |step|
        # Audit the step
        missing_steps[step.name] = step if step_missing?(step, step_defs)
        # Having audited the step, remove it from the list of unused steps
        unused_step_names.delete step.name
      end

      # If there are any steps left at the end, let's mark them as unused
      store_unused_steps(unused_step_names, step_defs)

      # And then generate a report of missing steps
      return true if missing_steps.empty?
      report_missing_steps(missing_steps.values)
      false
    end

    # Get the feature and its definitions from the appropriate files
    def get_feature_and_defs(file)
      feature = Parser.open_file(file).parse
      [feature, Spinach.find_step_definitions(feature.name)]
    end

    # Process a step from the feature file using the given step_defs.
    # If it is missing, return true. Otherwise, add it to the used_steps for
    # the report at the end and return false.
    def step_missing?(step, step_defs)
      method_name = Spinach::Support.underscore step.name
      return true unless step_defs.respond_to?(method_name)
      # Remember that we have used this step
      used_steps << step_defs.step_location_for(step.name).join(':')
      false
    end

    # Store any unused step names for the report at the end of the audit
    def store_unused_steps(names, step_defs)
      names.each do |name|
        location = step_defs.step_location_for(name).join(':')
        unused_steps[location] = name
      end
    end

    # Print a message alerting the user that there is no step file for this
    # feature
    def step_file_missing
      puts 'Step file missing: please run --generate first!'
        .colorize(:light_red)
      false
    end

    # Get the step names for all steps in the given class, including those in
    # common modules
    def step_names_for_class(klass)
      klass.ancestors.map { |a| a.respond_to?(:steps) ? a.steps : [] }.flatten
    end

    # Produce a report of unused steps that were not found anywhere in the audit
    def report_unused_steps
      # Remove any unused_steps that were in common modules and used
      # in another feature
      used_steps.each { |location| unused_steps.delete location }
      unused_steps.each do |location, name|
        puts "\n" + "Unused step: #{location} ".colorize(:yellow) +
             "'#{name}'".colorize(:light_yellow)
      end
    end

    # Print a report of the missing step objects provided
    def report_missing_steps(steps)
      puts "\nMissing steps:".colorize(:light_cyan)
      steps.each do |step|
        puts Generators::StepGenerator.new(step).generate.gsub(/^/, '  ')
          .colorize(:cyan)
      end
    end
  end
end
