class Fuu < Linkbot::Plugin

  register :regex => Regexp.new('FUUU')

  def self.on_message(message, matches)
    "http://imgur.com/M4KFN.jpg"
  end
end
