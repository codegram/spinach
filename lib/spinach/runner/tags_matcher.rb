module Spinach

  class TagsMatcher

    NEGATION_SIGN = '~'

    def initialize(scenario)
      @tags = scenario.tags
    end

    def match
      return true if tag_groups.empty?

      tag_groups.all? { |tag_group| match_tag_group(tag_group) }
    end

    private

    def tag_groups
      @tag_groups ||= Spinach.config.tag
    end

    def match_tag_group(tag_group)
      tag_group.any? do |tag|
        tag_matched = @tags.include?(tag.delete(NEGATION_SIGN))

        negated?(tag) ? !tag_matched : tag_matched
      end
    end

    def negated?(tag)
      tag.start_with? NEGATION_SIGN
    end

  end

end
