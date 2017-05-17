module Opalla
  module ComponentHelper
    def component(name, id: nil, model: nil, collection: nil)
      comp_id = (id || "#{name}-#{cidn_and_increment}")
      html    = component_html(name, id: id, model: model, collection: collection)
      output  = Nokogiri::HTML.fragment(html).children.attr(id: comp_id).to_s
      output.html_safe
    end

    def expose(variable_assignments)
      Opalla::Util.add_vars(variable_assignments)
    end

    protected

    def component_html(name, id: nil, model: nil, collection: nil)
      options = { partial: "components/#{name}", locals: {} }
      model.nil?      || options[:locals][:model]      = model
      collection.nil? || options[:locals][:collection] = collection
      options[:locals].merge(Opalla::Util.vars)
      render(options)
    end

    def cidn
      @cidn ||= 0
    end

    def cidn_and_increment
      @cidn = cidn + 1
      @cidn - 1
    end
  end
end