require 'minitest/spec'
require_relative 'filesystem'

require 'simplecov'
require 'coveralls'

SimpleCov.formatter = Coveralls::SimpleCov::Formatter
if ENV['CI']
  require 'simplecov'

  SimpleCov.start do
    add_filter '/test/'
    add_filter '/features/'
  end
end


Spinach.hooks.after_run do |scenario|
  FileUtils.rm_rf(Filesystem.dirs)
end
