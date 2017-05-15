require 'sha1.js'

module Opalla
  module HexRandom
    def self.[]
      x = rand.to_s
      y = Time.new.strftime("%S%L")
      z = "#{x}#{y}"
      `sha1.hex(#{z})`
    end
  end
end
