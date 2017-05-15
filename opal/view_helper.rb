module Opalla
  module TagHelper
    BOOLEAN_ATTRIBUTES = %w(allowfullscreen async autofocus autoplay checked
                            compact controls declare default defaultchecked
                            defaultmuted defaultselected defer disabled
                            enabled formnovalidate hidden indeterminate inert
                            ismap itemscope loop multiple muted nohref
                            noresize noshade novalidate nowrap open
                            pauseonexit readonly required reversed scoped
                            seamless selected sortable truespeed typemustmatch
                            visible).to_set

    BOOLEAN_ATTRIBUTES.merge(BOOLEAN_ATTRIBUTES.map(&:to_sym))

    TAG_PREFIXES = ["aria", "data", :aria, :data].to_set

    PRE_CONTENT_STRINGS             = Hash.new { "" }
    PRE_CONTENT_STRINGS[:textarea]  = "\n"
    PRE_CONTENT_STRINGS["textarea"] = "\n"

    class TagBuilder #:nodoc:
      VOID_ELEMENTS = %i(area base br col embed hr img input keygen link meta param source track wbr).to_set

      def initialize(view_context)
        @view_context = view_context
      end

      def tag_string(name, content = nil, escape_attributes: true, **options, &block)
        content = @view_context.capture(self, &block) if block_given?
        if VOID_ELEMENTS.include?(name) && content.nil?
          "<#{name.to_s.dasherize}#{tag_options(options, escape_attributes)}>"
        else
          content_tag_string(name.to_s.dasherize, content || "", options, escape_attributes)
        end
      end

      def content_tag_string(name, content, options, escape = true)
        tag_options = tag_options(options, escape) if options
        "<#{name}#{tag_options}>#{PRE_CONTENT_STRINGS[name]}#{content}</#{name}>"
      end

      def tag_options(options, escape = true)
        return if options.blank?
        output = "".dup
        sep    = " "
        options.each_pair do |key, value|
          if TAG_PREFIXES.include?(key) && value.is_a?(Hash)
            value.each_pair do |k, v|
              next if v.nil?
              output += sep
              output += prefix_tag_option(key, k, v, escape)
            end
          elsif BOOLEAN_ATTRIBUTES.include?(key)
            if value
              output += sep
              output += boolean_tag_option(key)
            end
          elsif !value.nil?
            output += sep
            output += tag_option(key, value, escape)
          end
        end
        output unless output.empty?
      end

      def boolean_tag_option(key)
        %(#{key}="#{key}")
      end

      def tag_option(key, value, escape)
        if value.is_a?(Array)
          value = value.join(" ".freeze)
        else
          value = value.to_s
        end
        %(#{key}="#{value.gsub('"'.freeze, '&quot;'.freeze)}")
      end

      private
        def prefix_tag_option(prefix, key, value, escape)
          key = "#{prefix}-#{key.to_s.dasherize}"
          unless value.is_a?(String) || value.is_a?(Symbol) || value.is_a?(Numeric)
            value = value.to_json
          end
          tag_option(key, value, escape)
        end

        def respond_to_missing?(*args)
          true
        end

        def method_missing(called, *args, &block)
          tag_string(called, *args, &block)
        end
    end

    def tag(name = nil, options = nil, open = false, escape = true)
      if name.nil?
        tag_builder
      else
        "<#{name}#{tag_builder.tag_options(options, escape) if options}#{open ? ">" : " />"}"
      end
    end

    def content_tag(name, content_or_options_with_block = nil, options = nil, escape = true, &block)
      if block_given?
        options = content_or_options_with_block if content_or_options_with_block.is_a?(Hash)
        tag_builder.content_tag_string(name, capture(&block), options, escape)
      else
        tag_builder.content_tag_string(name, content_or_options_with_block, options, escape)
      end
    end

    def cdata_section(content)
      splitted = content.to_s.gsub(/\]\]\>/, "]]]]><![CDATA[>")
      "<![CDATA[#{splitted}]]>"
    end

    def escape_once(html)
      ERB::Util.html_escape_once(html)
    end

    private
      def tag_builder
        @tag_builder ||= TagBuilder.new(self)
      end
  end

  module ViewHelper
    def link_to(name = nil, options = nil, html_options = nil, &block)
      html_options, options, name = options, name, block if block_given?
      options ||= {}

      html_options = convert_options_to_data_attributes(options, html_options)

      url = options
      html_options["href".freeze] ||= url

      content_tag("a".freeze, name || url, html_options, &block)
    end

    def content_tag(name, content_or_options_with_block = nil, options = nil, escape = true, &block)
      if block_given?
        options = content_or_options_with_block if content_or_options_with_block.is_a?(Hash)
        tag_builder.content_tag_string(name, capture(&block), options, escape)
      else
        tag_builder.content_tag_string(name, content_or_options_with_block, options, escape)
      end
    end

    protected

    def tag_builder
      @tag_builder ||= Opalla::TagHelper::TagBuilder.new
    end

    def convert_options_to_data_attributes(options, html_options)
      if html_options

        method = html_options.delete('method')

        add_method_to_attributes!(html_options, method) if method

        html_options
      end
    end
  end
end