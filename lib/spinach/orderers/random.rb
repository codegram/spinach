require 'digest'

module Spinach
  module Orderers
    class Random
      attr_reader :seed

      def initialize(seed:)
        @seed = seed.to_s
      end

      # Output the randomization seed in the report summary.
      #
      # @param [IO] io
      #   Output buffer for report.
      #
      # @api public
      def attach_summary(io)
        io.puts("Randomized with seed #{seed}\n\n")
      end

      # Returns a reordered version of the provided array
      #
      # @param [Array] items
      #   Items to order
      #
      # @api public
      def order(items)
        items.sort_by do |item|
          Digest::MD5.hexdigest(seed + item.ordering_id)
        end
      end
    end
  end
end
