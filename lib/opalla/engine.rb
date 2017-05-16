require 'rails'

module Opalla
  class Engine < ::Rails::Engine
    config.app_generators.javascript_engine :opal
    config.before_configuration do |app|
      js_folder = app.root.join(*%w[app assets javascripts]).to_s
      app.config.autoload_paths += ["#{js_folder}/lib"]
      app.config.autoload_paths += ["#{js_folder}/models"]
      app.config.assets.paths   += [File.expand_path('../../../opal', __FILE__)]
      # app.config.assets.paths   += Opal.paths
    end
  end
end
