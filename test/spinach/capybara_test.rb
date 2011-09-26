require 'test_helper'
require 'spinach/capybara'
require 'sinatra'

describe Spinach::Feature::Capybara do
  before do
    @sinatra_app = Sinatra::Application.new do
      get '/' do
        'Hello world!'
      end
    end
    Capybara.app = @sinatra_app
    @feature = Class.new(Spinach::Feature) do
      def go_home
        visit "/"
        page
      end
    end.new
  end
  it "goes to a capybara page" do
    page = @feature.go_home
    page.has_content?('Hello world').must_equal true
  end
end
