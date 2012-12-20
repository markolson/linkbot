class No < Linkbot::Plugin
  def self.on_message(message, matches)
    %w( http://i.imgur.com/Rd8xu.gif
        http://i.imgur.com/XWAvo.gif
        http://i.imgur.com/g9qfN.gif
        http://i.imgur.com/816uC.gif
        http://i.imgur.com/IzUaG.gif
        http://i.imgur.com/BVzQk.gif
        http://i.imgur.com/NpAbl.gif
        http://i.imgur.com/qkfZa.gif
      ).sample
  end

  Linkbot::Plugin.register('no', self, {
    :message => {:regex => /\An+o+[^\w]*\Z/i, :handler => :on_message}
  })
end

