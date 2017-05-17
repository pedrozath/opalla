module Opalla
  class Model
    def bind(*attributes, callback)
      @callbacks ||= []
      @callbacks << callback
      attributes.each do |attribute|
        define_singleton_method :"#{attribute}=" do |value|
          instance_variable_set :"@#{attribute}", value
          trigger_callbacks
        end
      end
    end

    def trigger_callbacks
      @callbacks.each(&:call)
    end
  end
end