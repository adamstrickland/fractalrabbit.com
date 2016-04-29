module Tag
  module Support
    def self.included(base)
      base.extend(ClassMethods)
    end

    def url
      self.class.url(@tag)
    end

    module ClassMethods
      def url(t)
        File.join("/tags", t.strip, "index.html")
      end
    end
  end
end
