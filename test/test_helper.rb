require 'minitest/autorun'
require 'minitest/spec'
require 'mocha/minitest'
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
