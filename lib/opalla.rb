require 'bundler'; Bundler.require
require 'active_support/dependencies'

require 'opal-browser'
require 'opalla/version'
require 'opalla/component_helper'
require 'opalla/engine'
require 'opalla/util'
require 'opalla/middleware'
require_relative '../opal/model'
require_relative '../opal/collection'

module Opalla
  include ActiveSupport::Dependencies
end

