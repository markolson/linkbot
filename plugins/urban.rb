class Define < Linkbot::Plugin
    def self.on_message(message, match, msg)
      word = URI.escape(match[0])
      doc = Hpricot(open("http://www.urbandictionary.com/define.php?term=#{word}").read)
      matches = doc.search("#entries td div[@class=definition]")
      if matches.empty?
        definition = "No definition for '#{match[0]}' found"
      else
        definition = "#{match[0]}: #{matches[0].inner_html}"
      end

      #ugh.
      definition = definition.gsub "<br />", "\n"

      [definition]
    end

    def self.help
      "!define (word) - use a dictionary, foo"
    end

    Linkbot::Plugin.register('urban', self,
      {
        :message => {:regex => /!define (.*)/, :handler => :on_message, :help => :help},
        :"direct-message" => {:regex => /!define (.*)/, :handler => :on_message, :help => :help}
      }
    )
end
