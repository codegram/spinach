module Spinach
  class Hooks

    def self.define_hook(hook)
      define_method hook do |&block|
        add_hook(hook, &block)
      end
      define_method "run_#{hook}" do |*args|
        run_hook(hook, *args)
      end
    end

    define_hook :before_run
    define_hook :after_run
    define_hook :before_feature
    define_hook :after_feature
    define_hook :on_undefined_feature
    define_hook :before_scenario
    define_hook :after_scenario
    define_hook :before_step
    define_hook :after_step
    define_hook :on_successful_step
    define_hook :on_failed_step
    define_hook :on_error_step
    define_hook :on_undefined_step
    define_hook :on_skipped_step

    def initialize
      @hooks = {}
    end

    def reset
      @hooks = {}
    end

    def run_hook(name, *args)
      if callbacks = @hooks[name.to_sym]
        callbacks.each{ |c| c.call(*args) }
      end
    end

    def hooks_for(name)
      @hooks[name.to_sym] || []
    end

    def add_hook(name, &block)
      @hooks[name.to_sym] ||= []
      @hooks[name.to_sym] << block
    end

  end
end
