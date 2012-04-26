gem 'minitest'

if ENV['COVERAGE']
  require 'simplecov'

  SimpleCov.start do
    add_filter '/test/'
    add_filter '/features/'
  end
end

require 'minitest/spec'
require 'minitest/autorun'
require 'mocha'
require 'ostruct'
require 'stringio'
require 'pry'
require 'turn'

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
