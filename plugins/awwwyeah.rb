class Awwyeah < Linkbot::Plugin
  def initialize
    register :regex => /a+w+ y+e+a+h+/i
  end

    def on_message(message, matches)
      "http://i.imgur.com/Y3Q0Z.png"
    end

end
