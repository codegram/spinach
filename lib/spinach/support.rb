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

    # Makes an underscored, lowercase form from the expression in the string.
    #
    # Changes '::' to '/' to convert namespaces to paths.
    #
    # Examples:
    #   "ActiveRecord".underscore         # => "active_record"
    #   "ActiveRecord::Errors".underscore # => active_record/errors
    #
    # As a rule of thumb you can think of +underscore+ as the inverse of +camelize+,
    # though there are cases where that does not hold:
    #
    #   "SSLError".underscore.camelize # => "SslError"
    def self.underscore(camel_cased_word)
      word = camel_cased_word.to_s.dup
      word.gsub!(/::/, '/')
      word.gsub!(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
      word.gsub!(/([a-z\\d])([A-Z])/,'\1_\2')
      word.tr!("-", "_")
      word.tr!(" ", "_")
      word.downcase!
      word
    end

    # Escapes the single commas of a given text. Mostly used in the {Generators}
    # classes
    #
    # @param [String] text
    #   The text to escape
    #
    # @return [String]
    #   The +text+ with escaped commas
    #
    # @example
    #   Spinach::Support.escape_single_commas("I've been bad")
    #   # => "I\'ve been bad"
    #
    def self.escape_single_commas(text)
      text.gsub("'", "\\\\'")
    end
  end
end
