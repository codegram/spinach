module Spinach

  module TagsMatcher

    NEGATION_SIGN = '~'

    class << self

      def match(tags)
        return true if tag_groups.empty?

        tag_groups.all? { |tag_group| match_tag_group(tag_group, tags) }
      end

      private

      def tag_groups
        Spinach.config.tag
      end

      def match_tag_group(tag_group, tags)
        tag_group.any? do |tag|
          tag_matched = tags.include?(tag.delete(NEGATION_SIGN))

          negated?(tag) ? !tag_matched : tag_matched
        end
      end

      def negated?(tag)
        tag.start_with? NEGATION_SIGN
      end

    end

  end

end
