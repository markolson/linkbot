require 'nokogiri'

class Hipster < Linkbot::Plugin

  def initialize
    register :regex => /!hipster/
    help "!hipster - Is it can be PBR tiem nao plox?"
  end

  def on_message(message, matches)
    url = URI.parse('http://api.automeme.net/text?vocab=hipster')

    res = http_get(url)
    meme = res.split("\n").first

    page = rand(150)
    url = "http://lookatthis!hnfuckinhipster.com"
    doc = Nokogiri::HTML(http_get("#{url}?p=#{page}"))
    imgs = doc.search("div.imagewrap img")
    img = url + imgs[rand(imgs.length)]["src"]

    [img, meme]
  end

end
