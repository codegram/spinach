module Spinach
  module Hookable

    def self.included(base)
      base.class_eval do
        extend ClassMethods
        include InstanceMethods
      end
    end

    module ClassMethods
      # Adds a new hook to this class. Every hook defines two methods used to
      # add new callbacks and to run them passing a bunch of parameters.
      #
      # @example
      #   class
      def define_hook(hook)
        define_method hook do |&block|
          add_hook(hook, &block)
        end
        define_method "run_#{hook}" do |*args|
          run_hook(hook, *args)
        end
      end
    end

    module InstanceMethods
      attr_writer :hooks

      def hooks
        @hooks ||= {}
      end

      # Resets all this class' hooks to a pristine state
      def reset
        self.hooks = {}
      end

      # Runs a particular hook
      #
      # @param [String] name
      #   the hook's name
      #
      # @param [
      def run_hook(name, *args)
        if callbacks = hooks[name.to_sym]
          callbacks.each{ |c| c.call(*args) }
        end
      end

      def hooks_for(name)
        hooks[name.to_sym] || []
      end

      def add_hook(name, &block)
        hooks[name.to_sym] ||= []
        hooks[name.to_sym] << block
      end
    end
  end
end
