
require_relative '../../test_helper'

describe Spinach::Runner::FeatureRunner do

  describe '#match' do

    before do
      @config = Spinach::Config.new
      Spinach.stubs(:config).returns(@config)
    end

    describe "when a single tag is passed" do

      before do
        @config.tag = [['wip']]
      end

      it "runs a scenario with matching tag" do
        @scenario = stub(tags: ['wip'])
        matcher = Spinach::TagsMatcher.new(@scenario)
        matcher.match.must_equal true
      end

      it "skips a scenario without matching tag" do
        @scenario = stub(tags: ['javascript'])
        matcher = Spinach::TagsMatcher.new(@scenario)
        matcher.match.must_equal false
      end

      it "skips a scenario without tags" do
        @scenario = stub(tags: [])
        matcher = Spinach::TagsMatcher.new(@scenario)
        matcher.match.must_equal false
      end
    end

    describe 'when a single negated tag is passed' do

      before do
        @config.tag = [['~wip']]
      end

      it "skips a scenario with matching tags" do
        @scenario = stub(tags: ['wip'])
        matcher = Spinach::TagsMatcher.new(@scenario)
        matcher.match.must_equal false
      end

      it "runs a scenario without matching tags" do
        @scenario = stub(tags: ['javascript'])
        matcher = Spinach::TagsMatcher.new(@scenario)
        matcher.match.must_equal true
      end

      it "runs a scenario without tags" do
        @scenario = stub(tags: [])
        matcher = Spinach::TagsMatcher.new(@scenario)
        matcher.match.must_equal true
      end
    end

    describe 'when combining ORed and ANDend tags' do
      # Running scenarios which match: (@billing OR @WIP) AND @important
      # cucumber --tags @billing,@wip --tags @important

      before do
        @config.tag = [['billing', 'wip'], ['important']]
      end

      it "runs a scenario with matching tags" do
        @scenario = stub(tags: ['wip', 'important'])
        matcher = Spinach::TagsMatcher.new(@scenario)
        matcher.match.must_equal true
      end

      it "runs a scenario with matching tags" do
        @scenario = stub(tags: ['billing', 'important'])
        matcher = Spinach::TagsMatcher.new(@scenario)
        matcher.match.must_equal true
      end

      it "skips a scenario with one matching tags" do
        @scenario = stub(tags: ['important'])
        matcher = Spinach::TagsMatcher.new(@scenario)
        matcher.match.must_equal false 
      end

      it "skips a scenario with one matching tags" do
        @scenario = stub(tags: ['billing'])
        matcher = Spinach::TagsMatcher.new(@scenario)
        matcher.match.must_equal false 
      end

      it "skips a scenario without matching tags" do
        @scenario = stub(tags: ['javascript'])
        matcher = Spinach::TagsMatcher.new(@scenario)
        matcher.match.must_equal false 
      end
    end

    describe "when multiple tags are passed as separate params" do

      before do
        @config.tag = [['wip'], ['javascript']]
      end

      it "runs a scenario with matching tags" do
        @scenario = stub(line: 4, tags: ['wip', 'javascript'])
        matcher = Spinach::TagsMatcher.new(@scenario)
        matcher.match.must_equal true 
      end

      it "skips a scenario without all matching tags" do
        @scenario = stub(line: 4, tags: ['javascript'])
        matcher = Spinach::TagsMatcher.new(@scenario)
        matcher.match.must_equal false 
      end

      it "skips a scenario without matching tags" do
        @scenario = stub(line: 4, tags: ['foo'])
        matcher = Spinach::TagsMatcher.new(@scenario)
        matcher.match.must_equal false 
      end

      it "skips a scenario without tags" do
        @scenario = stub(line: 4, tags: [])
        matcher = Spinach::TagsMatcher.new(@scenario)
        matcher.match.must_equal false 
      end
    end

    describe "when multiple tags are passed as a comma-separated list" do

      before do
        @config.tag = [['wip', 'javascript']]
      end

      it "runs a scenario with all matching tags" do
        @scenario = stub(tags: ['wip', 'javascript'])
        matcher = Spinach::TagsMatcher.new(@scenario)
        matcher.match.must_equal true
      end

      it "runs a scenario with at least one matching tag" do
        @scenario = stub(tags: ['javascript'])
        matcher = Spinach::TagsMatcher.new(@scenario)
        matcher.match.must_equal true
      end

      it "skips a scenario without matching tags" do
        @scenario = stub(tags: ['foo'])
        matcher = Spinach::TagsMatcher.new(@scenario)
        matcher.match.must_equal false
      end

      it "skips a scenario without tags" do
        @scenario = stub(tags: [])
        matcher = Spinach::TagsMatcher.new(@scenario)
        matcher.match.must_equal false
      end
    end
  end
end
