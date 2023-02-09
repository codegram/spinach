require 'minitest/autorun'
require 'minitest/spec'
require_relative 'filesystem'

Spinach.hooks.after_scenario do |scenario|
  FileUtils.rm_rf(Filesystem.dirs)
end
