module Opalla
  class Component
    attr_reader :template, :events, :model, :collection, :components, :id

    def initialize(template: nil, model: nil, collection: nil, id: nil)
      template ||= "components/_#{component_name}"
      @template = Template["views/#{template}"]
      @components = []
      @id = id
      unless model.nil?
        @model = model
        register_bindings
      end
      unless collection.nil?
        @collection = collection
        bind_collection
      end
    end

    def render
      if @rendered.nil?
        @rendered = true
        html = Element[template.render(self)]
        @id = id || cid(cidn_and_increment)
        html.attr(:id, id)
        html
      else
        el.html(Element[template.render(self)].html())
        bind_events
      end
    end

    def el
      Element["##{id}"] if @rendered
    end

    def bind_events
      components.each do |comp|
        comp.bind_events
      end
      events_hash.nil? && return
      events_hash.each do |caller, method|
        event, selector = caller.split(' ', 2)
        el.find(selector).on event do |e|
          e.prevent
          case method
            when Symbol then send(method, e.element)
            when Proc   then instance_exec(e.element, &method)
          end
        end
      end
    end

    def component(name, options={})
      comp = Object::const_get("#{name.camelize}Component").new(options)
      @components << comp
      comp.render
    end

  protected

    def cidn
      n = self.class.instance_variable_get(:"@cidn")
      return(n) unless n.nil?
      self.class.instance_variable_set(:"@cidn", 0)
    end

    def cid
      "#{component_name}-#{cidn}"
    end

    def cidn_and_increment
      self.class.instance_variable_set :"@cidn", cidn + 1
      self.class.instance_variable_get(:"@cidn") - 1
    end

    def register_bindings
      bindings = self.class.instance_variable_get :@bindings
      bindings.nil? && return
      bind_model(*bindings)
    end

    def component_name
      self.class.to_s.underscore.gsub('_component', '')
    end

    def events_hash
      self.class.instance_variable_get :@events
    end

    def self.events(events_hash)
      @events = events_hash
    end

    def self.bind(*attributes, callback)
      callback ||= -> { render }
      @bindings = attributes
    end

    def bind_model(*attributes)
      model.extend(ModelBinding)
      model.bind *attributes, -> { render }
    end

    def bind_collection(*attributes)
      collection.extend(CollectionBinding)
      collection.bind *attributes, -> { render }
    end
  end
end