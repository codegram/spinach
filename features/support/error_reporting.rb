require_relative 'spinach_runner'

module Integration
  module ErrorReporting
    include Filesystem

    def check_error_messages(n = 1)
      @stderr.must_match failure_regex(n)
    end

    def check_backtrace(n = 1)
      @stderr.must_match failure_regex(n)
      @stderr.must_match /.*(minitest|rspec).*assert_equal/
    end

    private

    def failure_regex(n)
      /Failures \(#{n}\)/
    end
  end
end
