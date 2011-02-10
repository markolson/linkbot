require 'rubygems'
require 'db'
require 'base_dupe'

class Linkbot
  def self.match(user, message)
    Thread.new { 
      final_message = []
      Linkbot::Plugin.plugins.each {|k,v|
        next unless v[:ptr].respond_to(:on_message)
        if(message =~ v[:regex])
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
      print "\n----\n" + s + "\n---\n" if s.length > 1
      Linkbot.msg LINKCHAT, s if defined?(LINKCHAT) && s.length > 1
    }
  end
  
  class Plugin
    @@plugins = {}
    
    def self.plugins; @@plugins; end;

    def self.collect
      Dir["plugins/*.rb"].each {|file| load file }
    end
  
    def self.register(name, regex, s, &blk)
      @@plugins[name] = {:ptr => s, :regex => regex, :block => blk }
      
    end
  end
  
end

# test
if not defined?(LINKCHAT)
  user = {'id' => 123, 'username' => 'mark_olson' }
  Linkbot::Plugin.collect
  #Linkbot.match('mark', 'http://qwantz.com')
  Linkbot.match(user, 'http://qwantz.com')
  Linkbot.check_dupe(user,'http://qwantz.com')
  sleep(2)
end