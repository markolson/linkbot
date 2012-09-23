require 'rubygems'
require 'pp'
require './db'

class MessageType
  MESSAGE       = :message
  DIRECTMESSAGE = :"direct-message"
  STARRED       = :starred
  UNSTARRED     = :unstarred
end

#The interface message object between Linkbot::Plugin and the plugins.
#New axiom: the plugins know nothing about the service they're using!
Message = Struct.new(:body, :user_id, :user_name, :connector, :type, :options)

Response = Struct.new(:message, :options)

module Linkbot  
  class Plugin
    @@plugins = {}
    @@message_logs = {}
    @@message_logs[:global] = []
    
    def self.handle_message(message)
      @@message_logs[:global] << message
      
      # Check for a room-wide message
      if message[:options][:room]
        @@message_logs[message[:options][:room]] ||= []
        @@message_logs[message[:options][:room]] << message
      end
      
      # Check for a user-specific message
      if message[:options][:user]
         @@message_logs[message[:options][:user]] ||= []
         @@message_logs[message[:options][:user]] << message 
      end

      final_message = []

      Linkbot::Plugin.plugins.each {|k,v|
        if v[:handlers][message.type] && v[:handlers][message.type][:handler]
          
          if ((v[:handlers][message.type][:regex] && v[:handlers][message.type][:regex].match(message.body)) || v[:handlers][message.type][:regex].nil?)
            
            matches = v[:handlers][message.type][:regex] ? v[:handlers][message.type][:regex].match(message.body).to_a.drop(1) : nil
            p "#{k} processing message type #{message.type}"
            begin
              end_msg = v[:ptr].send(v[:handlers][message.type][:handler], message, matches)

              if !end_msg.empty?
                if end_msg.is_a? Array
                  final_message.concat(end_msg)
                else
                  final_message << end_msg
                end
              end
            rescue => e
              end_msg = "the #{k} plugin threw an exception: #{e.inspect}"
              puts e.inspect
              puts e.backtrace.join("\n")
            end
          end
        end  
      }
      puts "returning msgs from plugins:"
      pp final_message
      final_message
    end
    
    def self.handle_periodic
      final_messages = []

      Linkbot::Plugin.plugins.each {|k,v|
        if v[:handlers][:periodic] && v[:handlers][:periodic][:handler]

          p "#{k} processing periodic message"
          begin
            #messages should be a hash {:messages => [<message:string>],
            #                           :options => {"room": <room:string>}
            #                          }
            messages = v[:ptr].send(v[:handlers][:periodic][:handler])

            if !messages[:messages].empty?
              final_messages << messages
            end
          rescue Exception => e
            final_messages << "the #{k} plugin threw an exception: #{e.inspect}"
            puts e.inspect
            puts e.backtrace.join("\n")
          end
        end
      }

      if final_messages.length
        print "returning msgs from periodic plugins:"
        pp final_messages
      end
      final_messages
    end

    def self.message_history(message)
      if message[:options][:room]
        @@message_logs[message[:options][:room]]
      elsif message[:options][:user]
        @@message_logs[message[:options][:user]]
      else
        @@message_logs[:global]
      end
    end
    
    def self.create_log(log_name)
      @@message_logs[log_name] ||= []
    end
    
    def self.log(log_name, message)
      if @@message_logs[log_name].length >= 100
        @@message_logs[log_name].pop
      end
      @@message_logs[log_name].unshift(message)
    end
    
    def self.registered_methods
      @registered_methods ||= {}
      @registered_methods
    end
    
    def self.plugins; @@plugins; end;

    def self.collect
      Dir["plugins/*.rb"].each do |file| 
        begin
          load file
        rescue Exception => e
          puts "unable to load plugin #{file}"
          puts e
        end
      end
    end
  
    def self.register(name, s, handlers)
      @@plugins[name] = {:ptr => s, :handlers => handlers}
    end
  end
  
end
