class Helper < Linkbot::Plugin

  Linkbot::Plugin.register('help', self,
    {
      :message => {:regex => /!help/, :handler => :on_message},
      :"direct-message" => {:regex => /!help/, :handler => :on_message}
    }
  )

  def self.on_message(message, matches)
    messages = []
    Linkbot::Plugin.plugins.each {|k,v|
      if(v[:handlers][message.type] && v[:handlers][message.type][:help])
        begin
          messages << v[:ptr].send(v[:handlers][message.type][:help])
        rescue => e
          puts e.inspect
          puts e.backtrace.join("\n")
        end
      end
    }
    messages.sort! do |x,y|
      x =~ /([A-Za-z]+)/
      sort1 = $1
      y =~ /([A-Za-z]+)/
      sort2 = $1
      sort1 <=> sort2
    end
    messages.join("\n")
  end
end
