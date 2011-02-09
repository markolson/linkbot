require 'rubygems'

class Linkbot
  def self.match(user, message)
    Thread.new { 
      final_message = []
      Linkbot::Plugin.plugins.each {|k,v|
        if(message =~ v[:regex])
          p "#{k} matches: #{user} - #{message}"
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
      p "registered #{name}" if !@@plugins[name]
      @@plugins[name] = {:ptr => s, :regex => regex, :block => blk }
      
    end
  end
  
end

# test
if not defined?(LINKCHAT)
  Linkbot::Plugin.collect
  Linkbot.match("mark", "!sleep")
  sleep(20)
  Linkbot::Plugin.collect
  sleep(1)
  Linkbot.match("mark", "!sleep")
  sleep(10)
end