class Stab < Linkbot::Plugin
  Linkbot::Plugin.register('stab', self,
    {
      :message => {:regex => /\/stab(?: ([\w\s]+))?/, :handler => :on_message}
    }
  )
  
  def self.on_message(user, message, matches, msg)
    name = matches[0] || "everyone in the face"
    ["#{user['username']} stabs #{name}"]
  end
end