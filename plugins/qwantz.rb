class Qwantz < Linkbot::Plugin
  register :regex => /!qwantz/
  help "!qwantz - #{[
    "HILARIOUS OUTTAKES COMICS",
    "PHILOSOPHY COMICS",
    "UNINFORMED OPINIONS ABOUT ARCHAEOLOGY COMICS",
    "COMICS WITH NON-TWIST ENDINGS",
    "COMICS FROM THE FUTURE",
    "ENTHUSIASTIC USE OF OUTDATED CATCH-PHRASES COMICS",
    "BAD DECISIONS COMICS"
  ].sample}"

  def self.on_message(message, matches)
    doc = Hpricot(open('http://qwantz.com/index.php'))
    link = doc.search("div.randomquote a")[1]
    doc = Hpricot(open(link['href']))
    img = doc.search('img.comic')
    [link.inner_html.strip, img.first['src']]
  end
end
