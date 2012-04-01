module Spinach
  module TagsMatcher

    NEGATION_SIGN = '~'

    class << self

      # Matches an array of tags (e.g. of a scenario) against the tags present
      # in Spinach' runtime options.
      #
      # Spinach' tag option is an array which consists of (possibly) multiple
      # arrays containing tags provided by the user running the features and
      # scenarios. Each of these arrays is considered a tag group.
      #
      # When matching tags against the tags groups, the tags inside a tag group
      # are OR-ed and the tag groups themselves are AND-ed.
      def match(tags)
        return true if tag_groups.empty?

        tag_groups.all? { |tag_group| match_tag_group(tag_group, tags) }
      end

      private

      def tag_groups
        Spinach.config.tags
      end

      def match_tag_group(tag_group, tags)
        tag_group.any? do |tag|
          tag_matched = tags.include?(tag.delete(NEGATION_SIGN))

          if tag_negated?(tag)
            !tag_matched
          else
            tag_matched
          end
        end
      end

      def tag_negated?(tag)
        tag.start_with? NEGATION_SIGN
      end

    end
  end
end
