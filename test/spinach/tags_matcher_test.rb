require_relative '../test_helper'

describe Spinach::TagsMatcher do

  describe '#match' do

    before do
      @config = Spinach::Config.new
      Spinach.stubs(:config).returns(@config)
    end

    subject { Spinach::TagsMatcher }

    describe "when matching against a single tag" do

      before { @config.tags = [['wip']] }

      it "matches the same tag" do
        subject.match(['wip']).must_equal true
      end

      it "does not match a different tag" do
        subject.match(['important']).must_equal false
      end

      it "does not match when no tags are present" do
        subject.match([]).must_equal false
      end
    end

    describe 'when matching against a single negated tag' do

      before { @config.tags = [['~wip']] }

      it "returns false for the same tag" do
        subject.match(['wip']).must_equal false
      end

      it "returns true for a different tag" do
        subject.match(['important']).must_equal true
      end

      it "returns true when no tags are present" do
        subject.match([]).must_equal true
      end
    end

    describe 'when matching against a single negated tag and an added tag' do

      before { @config.tags = [['~wip', 'added']] }

      it "returns false for the same tag" do
        subject.match(['wip']).must_equal false
      end

      it "returns true for the added tag" do
        subject.match(['added']).must_equal true
      end
      
      it "returns false for a different tag" do
        subject.match(['important']).must_equal false
      end

      it "returns false when no tags are present" do
        subject.match([]).must_equal false
      end
    end

    describe "when matching against ANDed tags" do

      before { @config.tags = [['wip'], ['important']] }

      it "returns true when all tags match" do
        subject.match(['wip', 'important']).must_equal true
      end

      it "returns false when one tag matches" do
        subject.match(['important']).must_equal false
      end

      it "returns false when no tags match" do
        subject.match(['foo']).must_equal false
      end

      it "returns false when no tags are present" do
        subject.match([]).must_equal false
      end
    end

    describe "when matching against ORed tags" do

      before { @config.tags = [['wip', 'important']] }

      it "returns true when all tags match" do
        subject.match(['wip', 'important']).must_equal true
      end

      it "returns true when one tag matches" do
        subject.match(['important']).must_equal true
      end

      it "returns false when no tags match" do
        subject.match(['foo']).must_equal false
      end

      it "returns false when no tags are present" do
        subject.match([]).must_equal false
      end
    end

    describe 'when matching against combined ORed and ANDed tags' do

      before { @config.tags = [['billing', 'wip'], ['important']] }

      it "returns true when all tags match" do
        subject.match(['billing', 'wip', 'important']).must_equal true
      end

      it "returns true when tags from both AND-groups match" do
        subject.match(['wip', 'important']).must_equal true
        subject.match(['billing', 'important']).must_equal true
      end

      it "returns false when tags from one AND-group match" do
        subject.match(['important']).must_equal false
        subject.match(['billing']).must_equal false
      end

      it "returns false when no tags match" do
        subject.match(['foo']).must_equal false
      end

      it "returns false when no tags are present" do
        subject.match([]).must_equal false
      end
    end

  end
end
