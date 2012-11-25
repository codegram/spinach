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

        tag_groups.all? { |tag_group| 
          res = match_tag_group(Array(tag_group), tags) 
          res
        }
      end

      private

      def tag_groups
        Spinach.config.tags
      end

      def match_tag_group(tag_group, tags)
        matched_tags = tag_group.select { |tag| !tag_negated?(tag) }
        matched = if matched_tags.empty?
          true
        else
          !tags.empty? && matched_tags.any? { |tag| tags.include?(tag) }
        end

        negated_tags = tag_group.select { |tag| tag_negated? tag }
        negated = if tags.empty?
          false
        else
          negated_tags.any? {|tag| tags.include?(tag.delete(NEGATION_SIGN))}
        end

        !negated && matched
      end

      def tag_negated?(tag)
        tag.start_with? NEGATION_SIGN
      end

    end
  end
end
