module Opalla
  class Controller < Component
    attr_reader :el

    def initialize(action=nil, params=nil, template: nil)
      @bindings = {}
      register_exposed_objects
      super(template: "#{controller_name}/#{action}")
      @el = Document.body
      self.send(action)
    end

    def el
      @el
    end

    def render
      # target = Document.body.clone.html(template.render(self))
      # el.morph(Element[target])
      el.html(template.render(self))
      bind_events
    end

    def el_selector
      self.class.instance_variable_get :@el_selector
    end

  protected

    def register_exposed_objects
      Marshal.load($$.opalla_data)[:vars].each do |key, val|
        define_singleton_method(key) { val }
      end
    end

    def self.el(selector)
      @el_selector = selector
    end

    def bind(binding)
      @bindings.merge!(binding)
      binding.each do |key, attrs|
        model = send(key)
        id    = model.model_id
        model.bind(*attrs, -> { render })
        merge_events_hash({
          %Q(input [data-model-id="#{id}"] [data-bind]) => -> target do
            model.find(target)
            attr = target.data('bind')
            model.public_send(:"#{attr}=", target.value)
          end
        })
      end
    end

    def controller_name
      self.class.to_s.underscore.gsub('_controller', '')
    end
  end
end