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
require 'purdytest'
require 'stringio'
require 'pry'
require 'fakefs/safe'
require 'turn'

require 'spinach'
require 'spinach/capybara'

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
