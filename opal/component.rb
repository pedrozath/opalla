module Opalla
  class Component
    include ViewHelper
    attr_reader :template, :events, :model, :collection, :components, :id

    def initialize(template: nil, model: nil, collection: nil, id: nil)
      template  ||= "components/_#{component_name}"
      @template   = Template["views/#{template}"]
      @components = []
      @id         = id
      @resource   = @model = model unless model.nil?
      @resource   = @collection = collection unless collection.nil?
      register_bindings
    end

    def render
      if @rendered.nil?
        @rendered = true
        html = Element[template.render(self)]
        @id = id || cid(cidn_and_increment)
        html.attr(:id, id)
        html
      else
        target = Element[template.render(self)]
        el.morph(target).attr(:id, id)
        bind_events
      end
    end

    def el
      Element["##{id}"] if @rendered
    end

    def bind_events
      remove_events
      components.each &:bind_events
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

    def remove_events
      components.each &:remove_events
      events_hash.nil? && return
      events_hash.each do |caller, method|
        event, selector = caller.split(' ', 2)
        el.find(selector).off event
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

    def get_bindings
      self.class.instance_variable_get :@bindings
    end

    def register_bindings
      get_bindings.nil? && return
      if !@model.nil?
        bind_model
      elsif !@collection.nil?
        bind_collection
      end
      include_input_bindings
    end

    def include_input_bindings
      merge_events_hash({
        'input [data-bind]' => -> target do
          model = @resource.find(target)
          attr  = target.data('bind')
          model.public_send(:"#{attr}=", target.value)
        end
      })
    end

    def component_name
      self.class.to_s.underscore.gsub('_component', '')
    end

    def events_hash
      self.class.instance_variable_get(:@events) || {}
    end

    def merge_events_hash(new_hash)
      self.class.instance_variable_set(:@events, events_hash.merge(new_hash))
    end

    def self.events(events_hash)
      @events = events_hash
    end

    def self.bind(*attributes)
      @bindings = attributes
    end

    def bind_model
      model.nil? && return
      model.bind(*get_bindings, -> { render } )
    end

    def bind_collection
      (collection.nil? || get_bindings.nil?) && return
      collection.bind(*get_bindings, -> { render })
    end
  end
end