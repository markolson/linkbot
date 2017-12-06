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
      connector_path = File.join(File.dirname(__FILE__), '../..', 'connectors', '*.rb')
      Dir[connector_path].each {|file| self.load_connector(file) }
    end

    def self.load_connector(path)
      load path
    end

    def self.register(name, s)
      @@connectors[name] = s
    end
    
    def onmessage(&block)
      @callbacks << block
    end
    
    def invoke_callbacks(message,options = {})
      @callbacks.each { |c| c.call(message,options) }
    end
    
    def send_messages(messages,options = {})
    end
    
    def periodic()
      if @options["periodic"]
        EventMachine::defer(proc {
          Linkbot::Plugin.handle_periodic.each do |message|
            send_messages(message[:messages], message[:options])
          end
        })
      end
    end

  end
end
