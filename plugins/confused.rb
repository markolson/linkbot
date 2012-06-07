class Confused < Linkbot::Plugin
  def self.on_message(message, matches)
    imgs = [
      "http://i.imgur.com/I8CZK.gif",
      "http://i.imgur.com/sGnXV.gif",
      "http://i.imgur.com/8Djqh.gif",
      "http://i.imgur.com/P79tv.gif",
      "http://i.imgur.com/FgWuk.gif",
      "http://i.imgur.com/AhWNt.gif",
      "http://i.imgur.com/RftoI.gif",
      "http://i.imgur.com/57VNz.gif",
      "http://i.imgur.com/AEVLX.gif",
      "http://i.imgur.com/Zj5J9.gif",
      "http://i.imgur.com/6M2mZ.gif",
      "http://i.imgur.com/WFCbt.gif",
      "http://i.imgur.com/ZTwgj.gif",
      "http://i.imgur.com/D2YaW.gif",
      "http://gifs.gifbin.com/122011/1323882446_dog_confused_by_video.gif"]

    imgs[rand(imgs.length)]
  end

  Linkbot::Plugin.register('confused', self, {
      :message => {:regex => /^\?$/, :handler => :on_message}
  })
end
