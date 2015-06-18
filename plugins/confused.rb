class Confused < Linkbot::Plugin

  register :regex => /^\?$/
  
  def self.on_message(message, matches)
    [
    # confusion
      "http://i.imgur.com/I8CZK.gif", # confused sports fan
      "http://i.imgur.com/sGnXV.gif", # confused Get Smart
      "http://i.imgur.com/8Djqh.gif", # Shaq arms to heaven
      "http://i.imgur.com/FgWuk.gif", # Urkle
      "http://i.imgur.com/AhWNt.gif", # how I turned to look slowly at your mother
      "http://i.imgur.com/ZTwgj.gif", # confused chameleon
      "http://i.imgur.com/D2YaW.gif", # Loki watching a tennis match
      "http://i.imgur.com/OPJlD.gif", # confused Jersey boy
      "http://i.imgur.com/H4NJO.gif", # confused Costanza
      "http://i.imgur.com/7xsWB.gif", # uncomfortable Buscemi
      "http://i.imgur.com/jQRny.gif", # sad in South Park
      "http://i.imgur.com/pzEGC.gif", # confused Ryan Reynolds
      "http://i.imgur.com/F8HyK.gif", # confused puppy
      "http://i.imgur.com/5qOPW.gif", # Clint is confused or disgusted
      "http://i.imgur.com/gZfK8.gif", # We won! No, wait. What?
      "http://i.imgur.com/v3KaH.gif", # Hepburn does not approve
      "http://i.imgur.com/eK2eR.gif", # confused Jack Sparrow
      "http://gifs.gifbin.com/122011/1323882446_dog_confused_by_video.gif", # <-- that
      "http://media.tumblr.com/tumblr_m3owc6eTvy1qcv6is.gif", # shifty eyes at The Office
      "http://media.tumblr.com/tumblr_m3w1x4LYDp1r1biix.gif", # speechless Flynn
      "http://media.tumblr.com/tumblr_m29p06JMii1qhj4zv.gif", # Whaaaaat?
      "http://media.tumblr.com/tumblr_lvfkdpwHxa1ql85u5.gif", # Friday Heh heh whu?
      "http://media.tumblr.com/tumblr_m29ozq9wOR1qhj4zv.gif", # John Stewart whaaaat?
      "http://usatthebiglead.files.wordpress.com/2014/02/john-calipari-provides-for-one-of-the-best-gifs-ever-against-ole-miss.gif",
      "http://replygif.net/i/1102.gif", # Jennifer Lawrence "Wut?"
    # I'm out
      "http://i.imgur.com/P79tv.gif", # "I'm out," says Jerry Seinfeld
      "http://i.imgur.com/aQSx1.gif", # head shake
      "http://i.imgur.com/HDdb9.gif", # Civil War fuck it, I'm out
      "http://i.imgur.com/RKieq.gif", # 70's I'm out ... a window
      "http://i.imgur.com/Z4BmZ.gif", # I'm outta here with my folding chair
      "http://i.imgur.com/7PSiL.gif", # Grandpa Simpson in-and-out
      "http://i.imgur.com/dnj5I.gif", # I'm just going to lay down here.
      "http://i.imgur.com/t9kzu.gif", # I'm leaving before stupid rubs off
    # shock
      "http://i.imgur.com/RftoI.gif", # speechless soccer player
      "http://i.imgur.com/57VNz.gif", # shocked Austin Powers
      "http://i.imgur.com/AEVLX.gif", # awestruck Jurassic Park
      "http://i.imgur.com/dR0HO.gif", # dropped your beer, bro'saurus
      "http://i.imgur.com/1XHgK.gif", # shocked by the internet
      "http://i.imgur.com/c9D6x.gif", # What is that? Velvet?
      "http://media.tumblr.com/tumblr_m3w22h97Pi1r1biix.gif", # Michael Emerson OMG
    # computer rage
      "http://i.imgur.com/Zj5J9.gif", # Swanson throws PC in dumpster
      "http://i.imgur.com/KBDS1.gif", # Vulcan computer rage
      "http://media.tumblr.com/tumblr_lxr6jyQrLb1r3zat8.gif", # stick figure computer rage
    # fail
      "http://i.imgur.com/6M2mZ.gif", # slinky on fire
      "http://i.imgur.com/WFCbt.gif", # smack forehead
      "http://i.imgur.com/gKVY0.gif", # WHAT'D YOU DO??
      "http://i.imgur.com/AwyR1.gif", # bike on a half pipe fail
      "http://i.imgur.com/DqlyC.gif", # you're waving at me? oh, you're not.
    # WTF
      "http://i.imgur.com/rG0cG.gif", # soccer WTF
      "http://i.imgur.com/27J2H.gif", # Ted says it's fine.
      "http://i.imgur.com/GGpTV.gif", # I can't even with a ukulele
      "http://i.imgur.com/SkROg.gif", # hoodie WTF
      "http://i.imgur.com/KffH8.gif", # David Cross WTF
      "http://24.media.tumblr.com/tumblr_m4urzbTNQh1ql7adco4_250.gif", # scrappy WTF
      "http://media.tumblr.com/tumblr_m4m5kozJih1qdfept.gif", # Colin has a headache
      "http://media.tumblr.com/tumblr_m4az7ta2BW1robwvc.gif", # crazy Tyra
      "http://media.tumblr.com/tumblr_m1dqzccB3E1qlk46r.gif", # hyperventalating Spongebob
    ].sample
  end

end
