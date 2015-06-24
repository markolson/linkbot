class Say < Linkbot::Plugin

  def initialize
    register :regex => /^!say (.+)/i
    help "!say (phrase) - Make linkbot repeat after you. Not that useful."
  end

  def on_message(message, matches)
    "#{matches[0]}"
  end

end
