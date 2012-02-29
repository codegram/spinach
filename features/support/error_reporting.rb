require_relative 'spinach_runner'

module Integration
  module ErrorReporting
    include Filesystem

    def check_error_messages(n = 1)
      @stderr.must_match /Failures \(#{n}\)/
    end

    def check_backtrace(n = 1)
      @stderr.must_match /Failures \(#{n}\)/
      @stderr.must_match /gems.*(minitest|rspec).*assert_equal/
    end
  end
end
