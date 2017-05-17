require 'rails/generators'

module Opalla
  class InstallGenerator < Rails::Generators::Base
    desc 'Creates Opalla files'

    def create_folders
      %w[
        components
        controllers
        lib
        models
        collections
        views/components
      ].each {|dir| empty_directory js(dir) }
    end

    def create_basic_files
      create_file js('application.rb'), <<~APPLICATION
        require 'opalla'

        require_tree './lib'
        require_tree './models'
        require_tree './collections'
        require_tree './components'
        require_tree './controllers'
        require_tree './views'

        Document.ready? do
          Opalla::Router.start
        end
      APPLICATION

      delete_appjs = ask %q{
        I've just created the main app file (application.rb)
        Should I just delete your application.js, since you won't need it anymore?
        (If you say no, please be sure to remove it later, ok?)
        [Y/n]
      }

      remove_file(js('application.js')) if delete_appjs == 'Y'

      create_file js('components/application_component.rb'), <<~COMPONENT
        class ApplicationComponent < Opalla::Component
          # Code shared between all components go here
        end
      COMPONENT

      create_file js('controllers/application_controller.rb'), <<~CONTROLLER
        class ApplicationController < Opalla::Controller
          # Code shared between all controllers go here
        end
      CONTROLLER
    end

  protected

    def js(path)
      "app/assets/javascripts/#{path}"
    end
  end
end