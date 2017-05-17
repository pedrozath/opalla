require 'rails/generators'

module Opalla
  class ComponentGenerator < Rails::Generators::NamedBase
    def create_component
      create_file js("components/#{file_name}_component.rb"), <<~CONTROLLER
        class #{class_name}Component < ApplicationComponent
          # Feel free to write your component actions, bindings, events
        end
      CONTROLLER
    end

    def create_views
      ext = defined?(Haml) ? 'haml' : 'erb'
      create_file js("views/components/_#{file_name}.#{ext}"), <<~VIEW
      .#{file_name.parameterize}
        -# Component content
      VIEW
    end

  protected

    def js(path)
      "app/assets/javascripts/#{path}"
    end
  end
end