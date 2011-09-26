gem 'minitest'
require 'minitest/unit'
require 'minitest/autorun'
require 'mocha'
require 'ostruct'
require 'purdytest'

require 'spinach'
require 'spinach/capybara'

require 'stringio'

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
