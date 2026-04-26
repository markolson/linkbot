require 'cgi'
require 'nokogiri'

class Calc < Linkbot::Plugin

  def initialize
    register :regex => /!calc (.+)/i
  end

  def on_message(message, matches)
    query = CGI.escape(matches[0])
    url = "https://encrypted.google.com/search?hl=en&q=#{query}"
    doc = Nokogiri::HTML(http_get(url))

    begin
      answer = doc.css('h2').find {|x| x["class"] == 'r'}.inner_html
    rescue NoMethodError
      return ["unable to calculate #{matches[0]}"]
    end

    #hipchat doesn't support <sup>
    answer.gsub! /<sup>/, '^'
    answer.gsub! /<\/sup>/, ''

    #we're not allowed HTML entities, so replace &#215; with x
    answer.gsub! /&#215;/, "\u00d7"

    [answer]
  end
end
