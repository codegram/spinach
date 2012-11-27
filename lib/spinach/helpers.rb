module Spinach
  module Helpers
    class << self
      def constantize(string)
        names = string.split('::')
        names.shift if names.empty? || names.first.empty?

        constant = Object
        names.each do |name|
          constant = constant.const_defined?(name) ? constant.const_get(name) : constant.const_missing(name)
        end
        constant
      end
    end
  end
end
