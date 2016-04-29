module Tag
  class Cloud < ::Liquid::Tag
    safe = true

    def initialize(name, test, tokens)
      super
    end

    def render(context)
      cloud(context).map{ |t, w| render_tag(t, w) }.join("\n")
    end

    def render_tag(tag, weight)
      "<span style='font-size: #{sprintf("%d", weight * 100)}%'><a href='/tags/#{tag}/'>#{tag}</a></span>"
    end

    def tags(context)
      @tags ||= context.registers[:site].tags
    end

    def cloud(context)
      tags = tags(context)
      average = tags.map{ |t, p| p.length }.inject(0.0){ |sum, i| sum + i } / tags.length
      Hash[*tags.map do |tag, _posts|
        [tag, (_posts.length / average)]
      end.flatten]
    end
  end
end

::Liquid::Template.register_tag("tag_cloud", ::Tag::Cloud)
