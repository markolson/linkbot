class Qwantz < Linkbot::Plugin
    Linkbot::Plugin.register('qwantz', self,
      {
        :message => {:regex => /!qwantz/, :handler => :on_message, :help => :help},
        :"direct-message" => {:regex => /!qwantz/, :handler => :on_message, :help => :help}
      }
    )
  
    def self.on_message(message, matches)
        doc = Hpricot(open('http://qwantz.com/index.php'))
        link = doc.search("div.randomquote a")[1]
        doc = Hpricot(open(link['href']))
        img = doc.search('img.comic')
        "#{link.inner_html.strip}\n#{img.first['src']}"
    end
    
    def self.help
      helpers = [
      "HILARIOUS OUTTAKES COMICS",
      "PHILOSOPHY COMICS",
      "UNINFORMED OPINIONS ABOUT ARCHAEOLOGY COMICS",
      "COMICS WITH NON-TWIST ENDINGS",
      "COMICS FROM THE FUTURE",
      "ENTHUSIASTIC USE OF OUTDATED CATCH-PHRASES COMICS",
      "BAD DECISIONS COMICS"
      ]
      "!qwantz - #{helpers[rand(helpers.length)]}"
    end
end
