# encoding: utf-8
require 'bundler'
Bundler::GemHelper.install_tasks

require 'rake/testtask'
Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['./test/**/*_test.rb']
  t.loader = :direct
end

task :default => [:test]
