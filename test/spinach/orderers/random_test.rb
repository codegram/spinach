require_relative '../../test_helper'

describe Spinach::Orderers::Random do
  let(:orderer) { Spinach::Orderers::Random.new(seed: Spinach.config.seed) }

  describe "#attach_summary" do
    let(:io) { StringIO.new }

    it 'appends the seed' do
      orderer.attach_summary(io)

      io.string.must_match /Randomized\ with\ seed\ #{orderer.seed}/
    end
  end

  describe "#order" do
    Identifiable = Struct.new(:ordering_id)

    let(:items) { (1..10).map { |n| Identifiable.new(n.to_s) } }

    it "randomizes the items" do
      orderer.order(items).wont_equal items
    end

    it "always randomizes items the same way with the same seed" do
      orderer.order(items).must_equal orderer.order(items)
    end
  end

  describe "#initialize" do
    it "requires a seed parameter" do
      proc {
        Spinach::Orderers::Random.new
      }.must_raise ArgumentError

      Spinach::Orderers::Random.new(seed: 4)
    end
  end
end
