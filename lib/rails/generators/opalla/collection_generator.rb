require 'rails/generators'

module Opalla
  class CollectionGenerator < Rails::Generators::NamedBase
    def create_collection
      create_file js("collections/#{file_name}.rb"), <<~CONTROLLER
        class #{class_name} < Opalla::Collection
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