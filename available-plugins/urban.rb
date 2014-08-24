require 'uri'

class Define < Linkbot::Plugin
    def self.on_message(message, match)
      word = URI.escape(match[0])
      doc = JSON.parse(open("http://www.urbandictionary.com/iphone/search/define?term=#{word}").read)
      if doc["result_type"] == "exact" 
        "\"#{URI.decode(word)}\": " + doc["list"][0]["definition"] + "\n" + "Example usage: " + doc["list"][0]["example"]
      else
        "No match!"
      end
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
