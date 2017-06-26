require 'test_helper'

module Spinach
  describe Feature do
    describe "#lines_to_run=" do
      subject { Feature.new }

      before { subject.lines_to_run = [4, 12] }

      it 'writes lines_to_run' do
        subject.lines_to_run.must_equal [4, 12]
      end
    end

    describe '#run_every_scenario?' do
      subject { Feature.new }

      describe 'when no line constraints have been specified' do
        it 'is true' do
          subject.run_every_scenario?.must_equal true
        end
      end

      describe 'when line constraints have been specified' do
        before { subject.lines_to_run = [4, 12] }

        it 'is false' do
          subject.run_every_scenario?.must_equal false
        end
      end
    end
  end
end
