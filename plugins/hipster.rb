class Hipster < Linkbot::Plugin
    @@hipster_regex = Regexp.new(/^!hipster$/)
    @@himages =
      ["http://imgur.com/vNNgw.jpg", "http://imgur.com/UgzjE.jpg",
        "http://imgur.com/YGB6A.jpg", "http://imgur.com/LUWK8.jpg",
        "http://imgur.com/6E3JK.jpg", "http://imgur.com/tjfFM.jpg",
        "http://imgur.com/2cb4q.jpg", "http://imgur.com/iQ89L.jpg",
        "http://imgur.com/toQYU.jpg", "http://imgur.com/wOQLv.jpg",
        "http://imgur.com/Iis7H.jpg", "http://imgur.com/pjHXU.jpg",
        "http://imgur.com/GbLiX.jpg", "http://imgur.com/bgbAM.jpg",
        "http://imgur.com/eV0Q2.jpg", "http://imgur.com/HTSkK.jpg",
        "http://imgur.com/lL922.jpg", "http://imgur.com/wu98d.jpg",
        "http://imgur.com/QgqmD.jpg", "http://imgur.com/biA50.jpg",
        "http://imgur.com/7INwG.jpg", "http://imgur.com/zhr1S.jpg",
        "http://imgur.com/FmtqB.jpg", "http://imgur.com/d2lXt.jpg",
        "http://imgur.com/qVjhD.jpg", "http://imgur.com/eJWfw.jpg",
        "http://imgur.com/HlFzr.jpg", "http://imgur.com/18KYP.jpg",
        "http://imgur.com/ZunXi.jpg", "http://imgur.com/gZ6Z6.jpg",
        "http://imgur.com/fBX3A.jpg", "http://imgur.com/GNLhj.jpg",
        "http://imgur.com/BNoKP.jpg", "http://imgur.com/rvNNE.jpg",
        "http://imgur.com/o4u2Y.jpg", "http://imgur.com/FZKd4.jpg",
        "http://imgur.com/czUAt.jpg", "http://imgur.com/Gtg1I.jpg",
        "http://imgur.com/QfSnr.jpg", "http://imgur.com/zE1oP.jpg",
        "http://imgur.com/Ki8PU.jpg", "http://imgur.com/n4PtK.jpg",
        "http://imgur.com/jNcO0.jpg", "http://imgur.com/k99Vp.jpg",
        "http://imgur.com/7Khaf.jpg", "http://imgur.com/6Qobk.jpg",
        "http://imgur.com/vYQXY.jpg", "http://imgur.com/HD7AJ.jpg",
        "http://imgur.com/CLjx7.jpg", "http://imgur.com/qrXR4.jpg",
        "http://imgur.com/3TezU.jpg", "http://imgur.com/TMyiD.jpg"]

    def self.on_message(message, matches)
      res, location = nil, nil
      url = URI.parse('http://api.automeme.net/text?vocab=hipster')

      res = Net::HTTP.get(url)
      meme = res.split("\n").first

      page = rand(150)
      url = "http://lookatthisfuckinhipster.com"
      doc = Hpricot(open("#{url}?p=#{page}").read)
      imgs = doc.search("div[@class=imagewrap] img")
      img = url + imgs[rand(imgs.length)].attributes["src"]

      [img, meme]
    end

    def self.help
      "!hipster - Is it can be PBR tiem nao plox?"
    end

    Linkbot::Plugin.register('hipster', self,
      {
        :message => {:regex => /!hipster/, :handler => :on_message, :help => :help}
      }
    )
end
