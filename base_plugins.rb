require 'rubygems'

require 'db'
require 'base_dupe'

class Linkbot  
  class Plugin
    @@plugins = {}
    
    def self.match(user, message)
      Thread.new { 
        final_message = []
        Linkbot::Plugin.plugins.each {|k,v|
          msgtxt = message["message"]
          if(v[:ptr].respond_to?(:on_message) && msgtxt =~ v[:regex])
            p "#{k} matches: #{user['username']} - #{msgtxt}"
            begin
              end_msg = v[:ptr].on_message(user, msgtxt, v[:regex].match(msgtxt).to_a.drop(1)).join("\n")
            rescue => e
              end_msg = ["the #{k} plugin threw an exception"] 
              puts e.inspect
              puts e.backtrace.join("\n")
            end
            final_message << end_msg
          end
        }
        s = final_message.join("\n")

        print ">>>#{s}\n" if s.length > 1
        Linkbot.msg message["topic"]["id"], s if s.length > 1
      }
    end
    
    def self.starred(user, message)
      Thread.new {
        final_message = []
        
        Linkbot::Plugin.plugins.each {|k,v|
          if(v[:ptr].respond_to?(:on_starred))
            p "#{k} responding to starred message"
            begin
              end_msg = v[:ptr].on_starred(user, message['star']['message']['user'], message['star']['message']['message']).join("\n")
            rescue => e
              end_msg = ["the #{k} plugin threw an exception"] 
              puts e.inspect
              puts e.backtrace.join("\n")
            end
            final_message << end_msg
          end
        }
        
        s = final_message.join("\n")
        print ">>>#{s}\n" if s.length > 1
        if s.length > 1
          Linkbot.msg(LINKCHAT, s)
        end
      }
    end
    
    def self.unstarred(user, message)
      Thread.new {
        final_message = []
        
        Linkbot::Plugin.plugins.each {|k,v|
          if(v[:ptr].respond_to?(:on_unstarred))
            p "#{k} responding to unstarred message"
            begin
              end_msg = v[:ptr].on_unstarred(user, message['star']['message']['user'], message['star']['message']['message']).join("\n")
            rescue => e
              end_msg = ["the #{k} plugin threw an exception"] 
              puts e.inspect
              puts e.backtrace.join("\n")
            end
            final_message << end_msg
          end
        }
        
        s = final_message.join("\n")
        print ">>>#{s}\n" if s.length > 1
        Linkbot.msg LINKCHAT, s if s.length > 1
      }
    end
    
    def self.plugins; @@plugins; end;

    def self.collect
      Dir["plugins/*.rb"].each {|file| load file }
    end
  
    def self.register(name, regex, s)
      @@plugins[name] = {:ptr => s, :regex => regex }
    end
  end
  
end

def test(user, message)
  Linkbot::Plugin.match(user, message)
  Linkbot::Dupe.check_dupe(user, message)
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
