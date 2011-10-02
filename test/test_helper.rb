gem 'minitest'
require 'simplecov'

SimpleCov.start do
  add_filter '/test/'
end

require 'minitest/spec'
require 'minitest/autorun'
require 'mocha'
require 'ostruct'
require 'purdytest'
require 'stringio'

require 'spinach'
require 'spinach/capybara'

module Kernel
  def capture_stdout
    out = StringIO.new
    $stdout = out
    yield
    return out
  ensure
    $stdout = STDOUT
  end
end
