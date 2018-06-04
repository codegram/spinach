module Spinach
  module Orderers
    class Default
      def initialize(**options); end

      # Appends any necessary report output (by default does nothing).
      #
      # @param [IO] io
      #   Output buffer for report.
      #
      # @api public
      def attach_summary(io); end

      # Returns a reordered version of the provided array
      #
      # @param [Array] items
      #   Items to order
      #
      # @api public
      def order(items)
        items
      end
    end
  end
end
