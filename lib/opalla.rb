require 'bundler'; Bundler.require
require 'opal-browser'
require 'active_support/dependencies'
require 'opalla/version'
require 'opalla/engine'
require 'opalla/util'

module Opalla
  include ActiveSupport::Dependencies
  unloadable
end

