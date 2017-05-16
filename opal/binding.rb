module Opalla
  module Binding
    attr_accessor :components

    def bind(component, *attributes)
      @components ||= []
      @components << component
      attributes.each do |attribute|
        define_singleton_method :"#{attribute}=" do |value|
          instance_variable_set :"@#{attribute}", value
          trigger_change
        end
      end
    end

    def trigger_change
      @components.each &:render
    end
  end
end