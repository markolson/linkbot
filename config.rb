module Linkbot
  class Config
    @@settings = {}
    
    def self.[](x)
      @@settings[x]
    end
    
    def self.load
      begin
        @@settings = JSON.parse(open("config.json").read)
      rescue Errno::ENOENT
        puts "You must have a config.json file defined"
        exit(1)
      end
    end
  end
end