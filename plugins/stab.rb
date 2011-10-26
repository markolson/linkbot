class Stab < Linkbot::Plugin
  Linkbot::Plugin.register('stab', self,
    {
      :message => {:regex => /\/stab(?: ([\w\s]+))?/, :handler => :on_message}
    }
  )
  
  def self.on_message(message, matches)
    name = matches[0] || "everyone in the face"
    "#{message.user_name} stabs #{name}"
  end
end
