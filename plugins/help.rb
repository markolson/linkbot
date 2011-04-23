class Helper < Linkbot::Plugin
  
  Linkbot::Plugin.register('help', self,
    {
      :message => {:regex => /!help/, :handler => :on_message},
      :"direct-message" => {:regex => /!help/, :handler => :on_message}
    }
  )
  
  def self.on_message(user, text, matches, msg)
    messages = [] 
    Linkbot::Plugin.plugins.each {|k,v|
      if(v[:handlers][msg['kind'].to_sym] && v[:handlers][msg['kind'].to_sym][:help])
        messages << v[:ptr].send(v[:handlers][msg['kind'].to_sym][:help])
      end
    }
    messages
  end
end