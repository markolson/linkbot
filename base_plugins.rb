require 'rubygems'

require 'db'
require 'base_dupe'

class Linkbot
  def self.match(user, message)
    Thread.new { 
      final_message = []
      Linkbot::Plugin.plugins.each {|k,v|
        if(v[:ptr].respond_to?(:on_message) && message =~ v[:regex])
          p "#{k} matches: #{user['username']} - #{message}"
          begin
            end_msg = v[:ptr].on_message(user, message, v[:regex].match(message).to_a.drop(1)).join("\n")
          rescue => e
            end_msg = ["the #{k} plugin threw an exception"] 
            p e.inspect
          end
          final_message << end_msg
        end
      }
      s = final_message.join("\n")
      print ">>>#{s}\n" if s.length > 1
      Linkbot.msg LINKCHAT, s if defined?(LINKCHAT) && s.length > 1
    }
  end
  
  class Plugin
    @@plugins = {}
    
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
  Linkbot.match(user, message)
  Linkbot.check_dupe(user, message)
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