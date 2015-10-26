class Stab < Linkbot::Plugin

  def initialize
    register :regex => /\/stab(?: ([\w\s]+))?/
  end

  def on_message(message, matches)
    name = matches[0] || "everyone in the face"
    "#{message.user_name} stabs #{name}"
  end
end
