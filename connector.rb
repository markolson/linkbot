module Linkbot
  class Connector
    @@connectors = {}
    
    def initialize(options)
      @options = options
      @callbacks = []
    end

    def self.[](x)
      @@connectors[x]
    end

    def self.collect
      Dir["connectors/*.rb"].each {|file| load file }
    end

    def self.register(name, s)
      @@connectors[name] = s
    end
    
    def onmessage(&block)
      @callbacks << block
    end
    
    def process_message(message)
      @callbacks.each { |c| c.call(message) }
    end

  end
end