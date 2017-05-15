module Opalla
  class Model
    def initialize
      @model_id = HexRandom[]
    end

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

    def model_id
      @model_id
    end

    def trigger_callbacks
      @callbacks.each(&:call)
    end

    def data
      get_class_data.reduce({'model-id' => model_id}) do |memo, i|
        memo.merge({ i.to_s.dasherize => send(i) })
      end
    end

    def find(arg=nil)
      return self
    end

    protected

    def get_class_data
      self.class.instance_variable_get(:"@data_attrs") || {}
    end

    def self.data(*data_attrs)
      @data_attrs = data_attrs
      attrs = data_attrs.dup
      attrs.delete(:model_id)
      attr_reader *attrs
    end

  end
end