class Meh < Linkbot::Plugin

  def self.on_message(message, matches)
    "http://farm5.staticflickr.com/4122/4869449359_1576cf6d18_m.jpg"
  end

  Linkbot::Plugin.register('meh', self, {
    :message => {:regex => /^meh|.*[ ]meh([ ].*)?$/i, :handler => :on_message}
  })
end
