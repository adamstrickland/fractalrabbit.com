require_relative "support"
require "deep_merge"

module Tag
  class Page < ::Jekyll::Page
    include ::Tag::Support

    def initialize(site, tag, posts)
      @site = site
      @tag = tag

      self.ext = ".html"
      self.basename = "index"
      self.content = <<-EOS
{% for post in page.posts %}
<h3>{{ post.date | date: "%A %d.%m." }} &mdash; <a href="{{ post.url }}">{{ post.title }}</a></h3>

<p>{{ post.content | truncatewords: 20 }}</p>

<p>
{% if post.categories != empty %}
In {{ post.categories | array_to_sentence_string }}.
{% endif %}
{% if post.tags != empty %}
Tagged {{ post.tags | array_to_sentence_string }}.
</p>
{% endif %}
{% endfor %}
      EOS
      self.data = {
        "layout" => "default",
        "type" => "tag",
        "posts" => posts
      }
    end

    def render(layouts, site_payload)
      payload = {
        "page" => self.to_liquid,
        "paginator" => page.to_liquid
      }.deep_merge(site_payload)

      do_layout(payload, layouts)
    end

    def to_liquid
      self.data.deep_merge({ "url" => self.url, "content" => self.content })
    end

    def write(dest_prefix, dest_suffix = nil)
      dest = dest_prefix
      dest = File.join(dest, dest_suffix) if dest_suffix
      path = File.join(dest, CGI.unescape(self.url))
      FileUtils.mkdir_p(File.dirname(path))
      File.open(path, 'w') do |f|
        f.write(self.output)
      end
    end

    def html?
      true
    end
  end
end
