require 'aruba/api'

module Integration
  module ErrorReporting
    include Aruba::Api

    def check_error_messages(n = 1)
      all_stderr.must_match /Failures \(1\)/
    end

    def check_backtrace(n = 1)
      all_stderr.must_match /Failures \(1\)/
      all_stderr.must_match /gems.*(minitest|rspec).*assert_equal/
    end
  end
end
