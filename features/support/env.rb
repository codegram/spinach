require 'minitest/spec'
require_relative 'filesystem'

require 'simplecov'

if ENV['CI'] && !defined?(Rubinius)
  require 'coveralls'
  SimpleCov.formatter = Coveralls::SimpleCov::Formatter
  require 'simplecov'

  SimpleCov.start do
    add_filter '/test/'
    add_filter '/features/'
  end
end


Spinach.hooks.after_run do |scenario|
  FileUtils.rm_rf(Filesystem.dirs)
end
