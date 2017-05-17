require 'rails'

module Opalla
  class Engine < ::Rails::Engine
    config.before_configuration do |app|
      config.app_generators.javascript_engine :opalla
      app.middleware.use OpallaMiddleware
      js_folder = app.root.join(*%w[app assets javascripts]).to_s
      app.config.autoload_paths += ["#{js_folder}/lib"]
      app.config.autoload_paths += ["#{js_folder}/models"]
      app.config.autoload_paths += ["#{js_folder}/collections"]
      Opal.append_path File.expand_path('../../../opal', __FILE__)
    end

    ActiveSupport.on_load(:action_view) do
      include Opalla::ComponentHelper
    end

    config.after_initialize do |app|
      ActionController::Base.prepend_view_path "app/assets/javascripts/views/"
    end
  end
end
