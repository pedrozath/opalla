module Opalla
  class Collection
    attr_accessor :models
    alias_method :all, :models

    def initialize
      @models = []
    end

    def create(options)
      model_class.new(options)
    end

    def add(*attributes)
      model_class.new(*attributes)
      trigger_callbacks
    end

    def remove(model)
      models.model.delete(model)
    end

    def bind(*attributes, callback)
      @callbacks ||= []
      @callbacks << callback
      models.each {|m| bind(*attributes, callback) }
    end

    def trigger_callbacks
      @callbacks.empty? && return
      @callbacks.each(&:call)
    end

    protected

    def model_class
      Object::const_get("#{self.class.singularize}")
    end
  end
end