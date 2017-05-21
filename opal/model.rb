module Opalla
  class Model
    def bind(*attributes, callback)
      puts attributes
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

    def model_id
      @model_id ||= increment_class_id
    end

    def data
      get_class_data.reduce({}) do |memo, i|
        memo.merge({ i.dasherize => send(i) })
      end
    end

    def find(arg=nil)
      return self
    end

    protected

    def get_class_data
      self.class.instance_variable_get(:"@data_attrs")
    end

    def class_id
      _id = self.class.instance_variable_get :"@model_id"
      _id || self.class.instance_variable_set(:"@model_id", 0)
    end

    def increment_class_id
      _id = self.class.instance_variable_set(:"@model_id", class_id+1)
      _id-1
    end

    def self.data(*data_attrs)
      @data_attrs = data_attrs
      attrs = data_attrs.dup
      attrs.delete(:model_id)
      attr_reader *attrs
    end

  end
end