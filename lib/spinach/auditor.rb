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
      if clean
        puts "\nAudit clean - no missing steps.".colorize(:light_green)
      end

      true
    end

    private

    def audit_file(file)
      puts "\nAuditing: ".colorize(:magenta) + file.colorize(:light_magenta)

      # Find the feature definition and its associated step defs class
      feature = Parser.open_file(file).parse
      step_defs_class = Spinach.find_step_definitions(feature.name)
      if !step_defs_class
        puts "Step file missing: please run --generate first!".
          colorize(:light_red)
        return
      end
      step_defs = step_defs_class.new        
      unused_step_names = step_defs_class.ancestors.
        map { |a| a.respond_to?(:steps) ? a.steps : []  }.flatten
      missing_steps = []

      feature.scenarios.each do |scenario|
        scenario.steps.each do |step|
          method_name = Spinach::Support.underscore step.name
          if step_defs.respond_to?(method_name)
            # Remember the location so we can subtract from unused_steps 
            # at the end
            location = step_defs.step_location_for(step.name).join(':')
            used_steps << location
          else
            # OK - we can't find a step definition for this step - add it to
            # the missing steps unless there is already a missing step of the 
            # same name
            unless missing_steps.map(&:name).include?(step.name)
              missing_steps << step
            end
          end
          # Having audited the step, remove it from the list of unused steps
          unused_step_names.delete step.name
        end
      end

      # If there are any steps left at the end, let's mark them as unused
      unused_step_names.each do |name|
        location = step_defs.step_location_for(name).join(':')
        unused_steps[location] = name
      end

      # And then generate a report of missing steps
      if missing_steps.empty?
        return true
      else
        puts "\nMissing steps:".colorize(:light_cyan)
        missing_steps.each do |step|
          puts Generators::StepGenerator.new(step).generate.gsub(/^/, '  ').
            colorize(:cyan)
        end
        return false
      end
    end

    def report_unused_steps
      # Remove any unused_steps that were in common modules and used
      # in another feature
      used_steps.each { |location| unused_steps.delete location }
      unused_steps.each do |location, name|
        puts "\n" + "Unused step: #{location} ".colorize(:yellow) + 
          "'#{name}'".colorize(:light_yellow)
      end
    end

  end

end
