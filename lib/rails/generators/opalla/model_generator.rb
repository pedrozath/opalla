require 'rails/generators'

module Opalla
  class ModelGenerator < Rails::Generators::NamedBase
    def create_component
      create_file js("models/#{file_name}.rb"), <<~CONTROLLER
        class #{class_name} < Opalla::Model
          # attr_reader :attrs
        end
      CONTROLLER
    end

  protected

    def js(path)
      "app/assets/javascripts/#{path}"
    end
  end
end