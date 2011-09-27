require 'active_support/inflector/methods'

module Spinach
  # A module to offer common helpers
  module Support
    # A helper to camelize string that proxies ActiveSupport#camelize
    #
    # @param [String] name
    #
    # @returns [String]
    #
    # @example
    #   Spinach::Support.camelize('User authentication')
    #   => 'UserAuthentication'
    def self.camelize(name)
      ActiveSupport::Inflector.camelize(name.to_s.downcase.strip.squeeze(' ').gsub(' ','_'))
    end
  end
end
