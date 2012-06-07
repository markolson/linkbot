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
      "http://i.imgur.com/aQSx1.gif",
      "http://i.imgur.com/OPJlD.gif",
      "http://i.imgur.com/H4NJO.gif",
      "http://i.imgur.com/dR0HO.gif",
      "http://i.imgur.com/HDdb9.gif",
      "http://i.imgur.com/KBDS1.gif",
      "http://i.imgur.com/rG0cG.gif",
      "http://i.imgur.com/RKieq.gif",
      "http://i.imgur.com/7xsWB.gif",
      "http://i.imgur.com/gKVY0.gif",
      "http://i.imgur.com/Z4BmZ.gif",
      "http://i.imgur.com/7PSiL.gif",
      "http://i.imgur.com/27J2H.gif",
      "http://i.imgur.com/jQRny.gif",
      "http://i.imgur.com/TX4ZJ.gif",
      "http://i.imgur.com/GGpTV.gif",
      "http://i.imgur.com/OboIh.gif",
      "http://i.imgur.com/AwyR1.gif",
      "http://i.imgur.com/SkROg.gif",
      "http://i.imgur.com/DqlyC.gif",
      "http://i.imgur.com/CJTWO.gif",
      "http://i.imgur.com/pzEGC.gif",
      "http://i.imgur.com/F8HyK.gif",
      "http://i.imgur.com/1XHgK.gif",
      "http://i.imgur.com/KffH8.gif",
      "http://i.imgur.com/kPIEy.gif",
      "http://i.imgur.com/5qOPW.gif",
      "http://i.imgur.com/dnj5I.gif",
      "http://i.imgur.com/gZfK8.gif",
      "http://i.imgur.com/v3KaH.gif",
      "http://media.tumblr.com/tumblr_lxr6jyQrLb1r3zat8.gif",
      "http://gifs.gifbin.com/122011/1323882446_dog_confused_by_video.gif"]

    imgs[rand(imgs.length)]
  end

  Linkbot::Plugin.register('confused', self, {
      :message => {:regex => /^\?$/, :handler => :on_message}
  })
end
