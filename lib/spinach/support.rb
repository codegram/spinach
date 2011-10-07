module Spinach
  # A module to offer helpers for string mangling.
  #
  module Support
    # @param [String] name
    #   The name to camelize.
    #
    # @return [String]
    #   The +name+ in camel case.
    #
    # @example
    #   Spinach::Support.camelize('User authentication')
    #   => 'UserAuthentication'
    #
    # @api public
    def self.camelize(name)
      name.to_s.strip.split(/[^a-z0-9]/i).map{|w| w.capitalize}.join
    end
  end
end
