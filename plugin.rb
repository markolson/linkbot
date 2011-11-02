require 'rubygems'
require 'pp'
require 'db'

class MessageType
  MESSAGE       = :message
  DIRECTMESSAGE = :"direct-message"
  STARRED       = :starred
  UNSTARRED     = :unstarred
end

#The interface message object between Linkbot::Plugin and the plugins.
#New axiom: the plugins know nothing about the service they're using!
Message = Struct.new(:body, :user_id, :user_name, :connector, :type)

module Linkbot  
  class Plugin
    @@plugins = {}
    @@message_log = []
    
    def self.handle_message(message)
      print "handle_message got called with #{message}"

      @@message_log << message

      final_message = []

      Linkbot::Plugin.plugins.each {|k,v|
        if v[:handlers][message.type] && v[:handlers][message.type][:handler]
          
          if ((v[:handlers][message.type][:regex] && v[:handlers][message.type][:regex].match(message.body)) || v[:handlers][message.type][:regex].nil?)
            
            matches = v[:handlers][message.type][:regex] ? v[:handlers][message.type][:regex].match(message.body).to_a.drop(1) : nil
            p "#{k} processing message type #{message.type}"
            begin
              end_msg = v[:ptr].send(v[:handlers][message.type][:handler], message, matches)
            rescue => e
              end_msg = "the #{k} plugin threw an exception: #{e.inspect}"
              puts e.inspect
              puts e.backtrace.join("\n")
            end
            final_message << end_msg if !end_msg.empty?
          end
        end  
      }
      print "returning msgs from plugins:"
      pp final_message
      final_message
    end
    
    def self.handle_periodic
      final_message = []

      Linkbot::Plugin.plugins.each {|k,v|
        if v[:handlers][:periodic] && v[:handlers][:periodic][:handler]

          p "#{k} processing periodic message"
          begin
            end_msg = v[:ptr].send(v[:handlers][:periodic][:handler])
          rescue => e
            end_msg = "the #{k} plugin threw an exception: #{e.inspect}"
            puts e.inspect
            puts e.backtrace.join("\n")
          end
          final_message << end_msg if !end_msg.empty?
        end
      }
      print "returning msgs from periodic plugins:"
      pp final_message
      final_message
    end

    def self.message_history
      @@message_log
    end
    
    def self.registered_methods
      @registered_methods ||= {}
      @registered_methods
    end
    
    def self.plugins; @@plugins; end;

    def self.collect
      Dir["plugins/*.rb"].each {|file| load file }
    end
  
    def self.register(name, s, handlers)
      @@plugins[name] = {:ptr => s, :handlers => handlers}
    end
  end
  
end
