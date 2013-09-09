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

require 'minitest/autorun'
require 'minitest/spec'
require 'mocha/setup'
require 'ostruct'
require 'stringio'
require 'pry'
require 'fakefs/safe'

require 'spinach'

require_relative "support/filesystem"

module Kernel
  def capture_stdout
    out = StringIO.new
    $stdout = out
    $stderr = out
    yield
    return out.string
  ensure
    $stdout = STDOUT
    $stdout = STDERR
  end
end
