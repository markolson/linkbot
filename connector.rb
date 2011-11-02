module Linkbot
  class Connector
    @@connectors = {}
    
    attr_accessor :options
    
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
    
    def send_messages(messages)
    end
    
    def periodic()
      if @options["periodic"]
        EventMachine::defer(proc {
          messages = Linkbot::Plugin.handle_periodic
          send_messages(messages)
        })
      end
    end

  end
end