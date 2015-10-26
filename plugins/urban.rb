require 'uri'

class Define < Linkbot::Plugin

  def initialize
    register :regex => /!define (.*)/
    help "!define (word) - use a dictionary, foo"
  end

  def on_message(message, match)
    word = URI.escape(match[0])
    doc = JSON.parse(open("http://www.urbandictionary.com/iphone/search/define?term=#{word}").read)
    if doc["result_type"] == "exact"
      "\"#{URI.decode(word)}\": " + doc["list"][0]["definition"] + "\n" + "Example usage: " + doc["list"][0]["example"]
    else
      "No match!"
    end
  end

end
