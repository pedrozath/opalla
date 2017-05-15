require 'rails/generators'

module Opalla
  class AssetsGenerator < Rails::Generators::NamedBase
    def create_controller
      create_file js("controllers/#{file_name}_controller.rb"), <<~CONTROLLER
        class #{class_name}Controller < ApplicationController
          # Write your actions here!
        end
      CONTROLLER
    end

    def create_view_folder
      empty_directory js("views/#{file_name}")
    end

  protected

    def js(path)
      "app/assets/javascripts/#{path}"
    end
  end
end