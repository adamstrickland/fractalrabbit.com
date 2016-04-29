module Tag
  class Generator < ::Jekyll::Generator
    safe true

    def generate(site)
      site.tags.each do |tag, posts|
        site.pages << ::Tag::Page.new(site, tag, posts)
      end
    end
  end
end
