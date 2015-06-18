class Stab < Linkbot::Plugin

  register :regex => /\/stab(?: ([\w\s]+))?/
  
  def self.on_message(message, matches)
    name = matches[0] || "everyone in the face"
    "#{message.user_name} stabs #{name}"
  end
end
