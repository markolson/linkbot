require 'json'

module Linkbot
  class Config
    @@settings = {}

    def self.settings
      @@settings
    end

    def self.[](x)
      @@settings[x]
    end

    def self.[]=(x,y)
      @@settings[x] = y
    end

    def self.has_key?(key)
      return @@settings.has_key? key
    end

    def self.load(path)
      begin
        @@settings = JSON.parse(File.read(path))
      rescue Errno::ENOENT
        Linkbot.log.fatal "You must have a config/config.json file defined"
        exit(1)
      end
    end
  end
end
