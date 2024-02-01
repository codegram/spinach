require "fileutils"

module Filesystem
  def in_current_dir(&block)
    dir = "tmp/fs"
    FileUtils.mkdir_p(dir)
    Dir.chdir(dir, &block)
  ensure
    FileUtils.rm_rf(dir)
  end
end

if defined? MiniTest::Spec
  MiniTest::Spec.send(:include, Filesystem)
elsif defined? Minitest::Spec
  Minitest::Spec.send(:include, Filesystem)
end