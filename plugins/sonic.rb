require 'nokogiri'

class Sonic < Linkbot::Plugin

  def initialize
    register :regex => /!sonic/i
    help "!sonic - get a dumb random sonic gif"
  end

  def on_message(message, matches)
    page = rand(29)
    doc = Nokogiri::HTML(http_get("http://dumbrunningsonic.tumblr.com/page/#{page}"))
    imgs = doc.search("div.contentwrap img").map {|x| x["src"]}
    imgs[rand(imgs.length)]
  end

end
