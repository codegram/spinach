require 'aruba/api'

module Integration
  module SpinachRunner
    include Aruba::Api

    def self.included(base)
      base.class_eval do
        before do
          in_current_dir do
            FileUtils.rmdir('features')
          end
        end
      end
    end

    def run_feature(command, options={})
      options[:suite] ||= :minitest
      use_minitest if options[:suite] == :minitest
      run "../../bin/spinach #{command} #{options[:append]}"
    end

    def use_minitest
      write_file('features/support/minitest.rb',
                "require 'minitest/spec'")
    end
  end
end
