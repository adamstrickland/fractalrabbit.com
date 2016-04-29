require_relative "support"

module Tag
  class TagUrl < ::Liquid::Tag
    include ::Tag::Support

    def initialize(name, tag, options)
      super
      @tag = tag
    end

    def render(context)
      url
    end
  end
end

Liquid::Template.register_tag(:tag_url, ::Tag::TagUrl)
