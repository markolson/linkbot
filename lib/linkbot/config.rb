require 'yaml'

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
    
    def self.load(path)
      begin
        @@settings = YAML::load(File.open(path))
      rescue Errno::ENOENT
        puts "You must have a config.yml file defined"
        exit(1)
      end
    end
  end
end
