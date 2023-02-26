# typed: strict
require 'forwardable'

module Steuben
  class Config
    extend Forwardable
    def_delegators :@properties, :[], :[]=

    def initialize(config_json: "config.json")
      @properties = {
        config_json: config_json,
      }
    end

    def config_json
      self[:config_json]
    end
  end
end
