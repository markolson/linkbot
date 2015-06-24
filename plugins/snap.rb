class Snap < Linkbot::Plugin

  def initialize
    register :regex => /SNAP\!/
  end
  
  def on_message(message, matches)
    [ "http://i52.tinypic.com/302melk.gif",
      "http://www.youtube.com/watch?v=qL3TWooBGrI",
      "http://i51.tinypic.com/2roj8k0.jpg",
      "http://i3.photobucket.com/albums/y79/IJG/oh_snap.gif",
      "http://webimages.stephen-wright.net/house-ohsnap.gif",
      "http://www.gifsoup.com/webroot/animatedgifs/108696_o.gif"
    ].sample
  end
end
