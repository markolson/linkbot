require 'rubygems'
require 'db'

class Linkbot  
  class Plugin
    @@plugins = {}
    @@message_log = []
    
    def self.handle_message(user, message)
      
      Thread.new { 
        final_message = []
        Linkbot::Plugin.plugins.each {|k,v|
          msgtext = message["message"]
          
          if v[:handlers][message['kind'].to_sym] && v[:handlers][message['kind'].to_sym][:handler]
            
            if ((v[:handlers][message['kind'].to_sym][:regex] && v[:handlers][message['kind'].to_sym][:regex].match(msgtext)) || v[:handlers][message['kind'].to_sym][:regex].nil?)
              
              matches = v[:handlers][message['kind'].to_sym][:regex] ? v[:handlers][message['kind'].to_sym][:regex].match(msgtext).to_a.drop(1) : nil
              p "#{k} processing message type #{message['kind']}"
              begin
                end_msg = v[:ptr].send(v[:handlers][message['kind'].to_sym][:handler], user, msgtext, matches, message).join("\n")
              rescue => e
                end_msg = ["the #{k} plugin threw an exception"] 
                puts e.inspect
                puts e.backtrace.join("\n")
              end
              final_message << end_msg
            end
          end  
        }
        s = final_message.join("\n")

        if s.length > 1
          print ">>>#{s}\n"
          send_message(s,message)
        end
      }
    end
    
    def self.send_message(reply, original_message)
      case original_message['kind']
      when "message"
        Linkbot.msg("/topics/#{original_message["topic"]["id"]}/messages/create.json", reply)
      when "star","unstar"
        Linkbot.msg("/topics/#{LINKCHAT}/messages/create.json", reply)
      when "direct-message"
        Linkbot.msg("/messages/#{original_message["conversation_user_id"]}/create.json", reply)
      end
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

def test(user, message)
  Linkbot::Plugin.handle_message(user, message)
end

# test
if not defined?(LINKCHAT)
  Linkbot::Plugin.collect
  user = {'id' => 123, 'username' => 'mark_olson' }
  #test(user, 'http://qwantz.com')
  #sleep(1)
  test(user, 'FUUUUUUUU')
  sleep(5)
end
