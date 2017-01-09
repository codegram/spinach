require 'pry'

module Spinach
  # The auditor audits steps and determines if any are missing or obsolete.
  #
  # It is a subclass of Runner because it uses many of the Runner's features
  # when auditing.
  #
  class Auditor < Runner
    
    attr_accessor :unused_steps
    
    def initialize(filenames)
      super(filenames)
      @unused_steps = {}
    end    
    
    # audits features
    # @files [Array]
    #   filenames to audit
    def run
      require_dependencies
      
      # Find any missing steps in each file, and keep track of unused steps
      clean = true
      filenames.each do |file|
        clean &&= audit_file(file)
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
        puts "  Step file missing: please run --generate first!".colorize(:light_red)
        return
      end
      step_defs = step_defs_class.new        
      unused_step_names = step_defs_class.steps
      missing_steps = []
                      
      feature.scenarios.each do |scenario|
        scenario.steps.each do |step|
          method_name = Spinach::Support.underscore step.name
          if step_defs.respond_to?(method_name)
            # Do nothing for now
            # FIXME: Remove unused steps
          else
            # OK - we can't find a step definition for this step
            missing_steps << step
          end
          # Having audited the step, remove it from the list of unused steps
          unused_step_names.delete step.name
        end
      end
      
      # If there are any steps left at the end, let's mark them as obsolete
      unused_step_names.each do |name|
        location = step_defs.step_location_for(name)
        unused_steps[location.join ':'] = name
      end
      
      # And then generate a report of missing steps
      if missing_steps.length > 0
        puts "\nMissing steps:".colorize(:light_cyan)
        missing_steps.each do |step|        
          puts "\n"+Generators::StepGenerator.new(step).generate.gsub(/^/, '  ').colorize(:cyan)
        end
        return false
      end
      return true
    end
    
    def report_unused_steps
      unused_steps.each do |location, name|
        puts "\n" + "Unused step: #{location} ".colorize(:yellow) + "'#{name}'".colorize(:light_yellow)
      end
    end
    
  end
  
end