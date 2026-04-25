require 'nokogiri'

class Google < Linkbot::Plugin

  def initialize
    register :regex => /!google (.+)/
    help "!google <term>: return the first google result"
  end

  def on_message(message, matches)
    searchterm = URI.encode(matches[0])
    doc = Nokogiri::HTML(open("https://encrypted.google.com/search?q=#{searchterm}").read)
    doc.search("h3.r a")[0].to_s.match(/q=(.*?)&/)[1]
  end

end
