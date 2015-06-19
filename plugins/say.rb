class Say < Linkbot::Plugin

  register :regex => /^!say (.+)/i
  help "!say (phrase) - Make linkbot repeat after you. Not that useful."

  def self.on_message(message, matches)
    "#{matches[0]}"
  end

end
