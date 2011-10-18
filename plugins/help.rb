class Helper < Linkbot::Plugin
  
  Linkbot::Plugin.register('help', self,
    {
      :message => {:regex => /!help/, :handler => :on_message},
      :"direct-message" => {:regex => /!help/, :handler => :on_message}
    }
  )
  
  def self.on_message(text, matches, msg)
    messages = [] 
    Linkbot::Plugin.plugins.each {|k,v|
      if(v[:handlers][msg.type] && v[:handlers][msg.type][:help])
        messages << v[:ptr].send(v[:handlers][msg.type][:help])
      end
    }
    messages
  end
end
