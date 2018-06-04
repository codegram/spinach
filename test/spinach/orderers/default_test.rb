require_relative '../../test_helper'

describe Spinach::Orderers::Default do
  let(:orderer) { Spinach::Orderers::Default.new }

  describe "#attach_summary" do
    let(:io) { StringIO.new }

    it 'appends nothing' do
      contents_before_running = io.string.dup

      orderer.attach_summary(io)

      io.string.must_equal contents_before_running
    end
  end

  describe "#order" do
    let(:items) { Array(1..10) }

    it "doesn't change the order of the items" do
      orderer.order(items).must_equal items
    end
  end

  describe "#initialize" do
    it "can be provided options without raising an error" do
      Spinach::Orderers::Default.new(seed: "seed")
    end
  end
end
