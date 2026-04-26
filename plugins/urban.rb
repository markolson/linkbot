require 'uri'

class Define < Linkbot::Plugin

  def initialize
    register :regex => /!define (.*)/
    help "!define (word) - use a dictionary, foo"
  end

  def on_message(message, match)
    word = Addressable::URI.escape(match[0])
    doc = JSON.parse(http_get("http://www.urbandictionary.com/iphone/search/define?term=#{word}"))
    if doc["result_type"] == "exact"
      "\"#{Addressable::URI.unescape(word)}\": " + doc["list"][0]["definition"] + "\n" + "Example usage: " + doc["list"][0]["example"]
    else
      "No match!"
    end
  end

end
