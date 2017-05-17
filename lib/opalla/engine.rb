require 'rails'

module Opalla
  class Engine < ::Rails::Engine
    config.before_configuration do |app|
      config.app_generators.javascript_engine :opalla
      js_folder = app.root.join(*%w[app assets javascripts]).to_s
      app.config.autoload_paths += ["#{js_folder}/lib"]
      app.config.autoload_paths += ["#{js_folder}/models"]
      Opal.append_path File.expand_path('../../../opal', __FILE__)
    end
  end
end
