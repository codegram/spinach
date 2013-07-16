require 'test_helper'
require 'capybara'
require 'rack/test'
require 'spinach'
require 'spinach/capybara'
require 'sinatra/base'

class SinatraStubApp < Sinatra::Base
  get '/' do
    'Hello world!'
  end
end

describe Spinach::FeatureSteps::Capybara do
  before do
    Capybara.current_driver = :rack_test
    Capybara.app = SinatraStubApp

    class TestFeature < Spinach::FeatureSteps
      include Spinach::FeatureSteps::Capybara
      feature 'A test feature'
      Given 'Hello' do
      end
      Then 'Goodbye' do
      end
      Given 'Fail' do
        1.must_equal 2
      end
      def go_home
        visit '/'
        page
      end
    end

    @feature_class = TestFeature
    @feature = @feature_class.new
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

  let(:failing_feature) { Spinach::Parser.new("""
Feature: A test feature
  Scenario: A test scenario
    Given Fail
""").parse
  }

  it 'includes capybara into all features' do
    @feature.kind_of?(Capybara::DSL).must_equal true
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

    Capybara.expects(:javascript_driver).at_least(1)
    Capybara.expects(:current_driver=).at_least(1)

    @feature_runner.run
  end

  describe "when there's a failure" do
    it 'saves and open the page if the option is activated' do
      @feature_runner = Spinach::Runner::FeatureRunner.new(failing_feature)
      Spinach.config.save_and_open_page_on_failure = true
      @feature_class.any_instance.expects(:save_and_open_page).once
      Spinach.config.save_and_open_page_on_failure = false
      @feature_runner.run
    end

    it "doesn't saves and open the page if the option is deactivated" do
      @feature_runner = Spinach::Runner::FeatureRunner.new(failing_feature)
      Spinach.config.save_and_open_page_on_failure = false
      Capybara.expects(:save_and_open_page).never
      @feature_runner.run
    end
  end
end
