module Opalla
  class Controller < Component
    attr_reader :el

    def initialize(action=nil, params=nil, el: 'body', template: nil)
      register_exposed_objects
      super(template: "#{controller_name}/#{action}")
      @el = Element[el_selector || el]
      self.send(action)
    end

    def render
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

    def controller_name
      self.class.to_s.underscore.gsub('_controller', '')
    end

  end
end