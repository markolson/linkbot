class Define < Linkbot::Plugin
    def self.regex
      /!define (.*)/
    end
    Linkbot::Plugin.register('urban', self.regex, self)

    def self.on_message(user, message, match)
      word = URI.escape(match[0])
      doc = Hpricot(open("http://www.urbandictionary.com/define.php?term=#{word}").read)
      matches = doc.search("#entries td div[@class=definition]")
      if matches.empty?
        mymessage = "No definition for '#{match[0]}' found"
      else
        mymessage = "#{match[0]}: #{matches[0].inner_html}"
      end
      [mymessage]
    end

    def self.help
      "!define (word) - use a dictionary, foo"
    end
end
