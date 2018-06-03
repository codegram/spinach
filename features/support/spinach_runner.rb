require "rbconfig"
require_relative 'filesystem'

module Integration
  module SpinachRunner
    include Filesystem

    def self.included(base)
      Spinach.hooks.before_scenario do
        if respond_to?(:in_current_dir)
          in_current_dir do
            rmdir "rails_app"
          end
        end
      end
    end

    def run_feature(feature, options={})
      options[:framework] ||= :minitest
      use_minitest if options[:framework] == :minitest
      use_rspec if options[:framework] == :rspec
      spinach = File.expand_path("bin/spinach")
      run "#{ruby} #{spinach} #{feature} #{options[:append]}", options[:env]
    end

    def ruby
      return @ruby if defined?(@ruby)

      config = RbConfig::CONFIG
      @ruby = File.join(config["bindir"],
                  "#{config["ruby_install_name"]}#{config["EXEEXT"]}")
    end

    def use_minitest
      write_file('features/support/minitest.rb',
                "require 'minitest/spec'")
    end

    def use_rspec
      write_file('features/support/minitest.rb',
                "require 'rspec/core'\nrequire 'rspec/expectations'")
    end
  end
end
