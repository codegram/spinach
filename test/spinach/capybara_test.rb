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

  let(:parsed_feature) { Spinach::Parser.new("""
Feature: A test feature
  Scenario: A test scenario
    Given Hello
    Then Goodbye

  @javascript
  Scenario: Another test scenario
    Given Hello
    Then Goodbye
""").parse
  }

  it 'includes capybara into all features' do
    @feature.kind_of? Capybara
  end

  it 'goes to a capybara page and returns its result' do
    page = @feature.go_home
    page.has_content?('Hello world').must_equal true
  end

  it 'resets the capybara session after each scenario' do
    @feature_runner = Spinach::Runner::FeatureRunner.new(parsed_feature)

    Capybara.current_session.expects(:reset!).at_least_once

    @feature_runner.run
  end

  it 'resets the javascript driver after each scenario' do
    @feature_runner = Spinach::Runner::FeatureRunner.new(parsed_feature)

    Capybara.expects(:use_default_driver).at_least(2)

    @feature_runner.run
  end

  it 'changes the javascript driver when an scenario has the @javascript tag' do
    @feature_runner = Spinach::Runner::FeatureRunner.new(parsed_feature)

    Capybara.expects(:javascript_driver).once.returns('javascript')
    Capybara.expects(:current_driver=).once

    @feature_runner.run
  end
end
