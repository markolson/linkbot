class Google < Linkbot::Plugin
  Linkbot::Plugin.register('google', self,
    {
      :message => {:regex => /!google (.+)/, :handler => :on_message, :help => :help}
    }
  )

  def self.on_message(message, matches)
    searchterm = URI.encode(matches[0])
    doc = Hpricot(open("https://encrypted.google.com/search?q=#{searchterm}").read)
    doc.search("h3[@class=r] a")[0].to_s.match(/q=(.*?)&/)[1]
  end

  def self.help
    "!google <term>: return the first google result"
  end
end
