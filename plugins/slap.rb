class Slap < Linkbot::Plugin
  def initialize
    register :regex => /\/slap(?: ([\w\s]+))?/
    help "/slap [username] - Flashback to the halcyon days of the 1990s when hammer pants were all the rage"
  end

  def on_message(message, matches)
    if matches[0] and matches[0].length > 0
      user = matches[0]
    else
      user = "everyone"
    end

    "#{message.user_name} slaps #{user} around a bit with a large trout"
  end

end
