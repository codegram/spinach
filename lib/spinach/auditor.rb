require 'pry'

module Spinach
  # The auditor audits steps and determines if any are missing or obsolete.
  #
  # It is a subclass of Runner because it uses many of the Runner's features
  # when auditing.
  #
  class Auditor < Runner
    # audits features
    # @files [Array]
    #   filenames to audit
    def run
      require_dependencies
      
      filenames.each do |file|        
        feature = Parser.open_file(file).parse
        step_defs_class = Spinach.find_step_definitions(feature.name)
        if !step_defs_class
          puts "No definitions!"
          next
        end
        step_defs = step_defs_class.new        
        step_names = step_defs_class.steps
                        
        feature.scenarios.each do |scenario|
          scenario.steps.each do |step|
            method_name = Spinach::Support.underscore step.name
            if step_defs.respond_to?(method_name)
              puts "Found step '#{step.name}'"
            else
              puts Generators::StepGenerator.new(step).generate.gsub(/^/, '  ')
            end
            step_names.delete step.name # we've audited this step
          end
        end
        
        # If there are any steps left at the end, let's mark them as obsolete
        step_names.each do |obsolete_name|
          location = []
          begin
            location = step_defs.method(Spinach::Support.underscore obsolete_name).source_location
          rescue NameError
            # if the method doesn't exist, just leave location as empty
          end
          puts "Unused step: #{location.join ':'} '#{obsolete_name}'"
        end
      end
      true
    end
  end
end