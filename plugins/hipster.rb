require 'nokogiri'

class Hipster < Linkbot::Plugin

  def initialize
    register :regex => /!hipster/
    help "!hipster - Is it can be PBR tiem nao plox?"
  end

  def on_message(message, matches)
    url = URI.parse('http://api.automeme.net/text?vocab=hipster')

    res = Net::HTTP.get(url)
    meme = res.split("\n").first

    page = rand(150)
    url = "http://lookatthisfuckinhipster.com"
    doc = Nokogiri::HTML(open("#{url}?p=#{page}").read)
    imgs = doc.search("div.imagewrap img")
    img = url + imgs[rand(imgs.length)]["src"]

    [img, meme]
  end

end
