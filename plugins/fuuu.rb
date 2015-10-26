class Fuu < Linkbot::Plugin

  def initialize
    register :regex => Regexp.new('FUUU')
  end

  def on_message(message, matches)
    "http://imgur.com/M4KFN.jpg"
  end
end
