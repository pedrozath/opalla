module Opalla
  class Collection
    attr_accessor :models
    alias_method :all, :models

    def initialize(models=nil)
      @models = models || []
    end

    def create(options)
      model_class.new(options)
    end

    def add(*attributes)
      new_model = model_class.new(*attributes)
      bindings.each {|b| new_model.bind(*b[:attributes], b[:callback])}
      models << new_model
      trigger_callbacks
    end

    def remove(arg)
      case arg
      when Element, Numeric, String then models.delete(find(arg))
      else models.delete(arg)
      end
      trigger_callbacks
    end

    def find(arg)
      case arg
      when Numeric, String
        id = arg.to_i
        models.each do |model|
          return model if model.model_id == id
        end
      when Element
        sel = '[data-model-id]'
        if arg.is(sel)
          find(arg.data('model_id'))
        else
          find(arg.closest('[data-model-id]').data('model-id'))
        end
      end
    end

    def bind(*attributes, callback)
      @bindings ||= []
      @bindings << { attributes: attributes, callback: callback }
      models.each {|m| m.bind(*attributes, callback) }
    end

    def bindings
      @bindings || []
    end

    def trigger_callbacks
      callbacks.empty? && return
      callbacks.each(&:call)
    end

    def callbacks
      @bindings.map { |b| b[:callback] }
    end

    protected

    def model_class
      Object::const_get("#{self.class.to_s.singularize}")
    end
  end
end