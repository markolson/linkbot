class Define < Linkbot::Plugin
    def self.on_message(message, match)
      word = URI.escape(match[0])
      doc = Hpricot(open("http://www.urbandictionary.com/define.php?term=#{word}").read)
      definition = doc.search("#entries td div[@class=definition]")
      if definition.empty?
        message = "No definition for '#{match[0]}' found"
      else
        definition = definition[0].inner_html.gsub("<br />", "\n")
        definition = Sanitize.clean(definition)
        message = "#{match[0]}: #{definition}"
      end

      message
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
