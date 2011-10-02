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
      name.to_s.strip.split(/[^a-z0-9]/i).map{|w| w.capitalize}.join
    end
  end
end
