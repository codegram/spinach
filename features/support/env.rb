require 'minitest/spec'
require_relative 'filesystem'

Spinach.hooks.after_run do |scenario|
  FileUtils.rm_rf(Filesystem.dirs)
end
