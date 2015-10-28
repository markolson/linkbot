class Toothpaste < Linkbot::Plugin
  def initialize
    register :regex => /!toothpaste/
  end

  def on_message(message, matches)
    doc = Hpricot(open('http://www.toothpastefordinner.com/randomComicViewer.php'))
    img = doc.search('#comicarea img')
    link = doc.search('div.headertext a:first').text()
    [link.strip, img.first['src']]
  end
end
