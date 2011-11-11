require 'test_helper'
require 'spinach'
require 'spinach/capybara'
require 'sinatra'

describe Spinach::FeatureSteps::Capybara do
  before do
    @sinatra_app = Sinatra::Application.new do
      get '/' do
        'Hello world!'
      end
    end

    Capybara.app = @sinatra_app

    @feature = Class.new(Spinach::FeatureSteps) do
      include Spinach::FeatureSteps::Capybara
      feature 'A test feature'
      Given 'Hello' do
      end
      Then 'Goodbye' do
      end
      def go_home
        visit '/'
        page
      end
    end.new
  end

  it 'includes capybara into all features' do
    @feature.kind_of? Capybara
  end

  it 'goes to a capybara page and returns its result' do
    page = @feature.go_home
    page.has_content?('Hello world').must_equal true
  end

  it 'resets the capybara session after each scenario' do
    feature = Spinach::Parser.new("""
Feature: A test feature
  Scenario: A test scenario
    Given Hello
    Then Goodbye
  Scenario: Another test scenario
    Given Hello
    Then Goodbye
""").parse

    @feature_runner = Spinach::Runner::FeatureRunner.new(feature)

    Capybara.current_session.expects(:reset!).at_least_once

    @feature_runner.run
  end
end
