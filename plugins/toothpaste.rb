require 'nokogiri'

class Toothpaste < Linkbot::Plugin
  def initialize
    register :regex => /!toothpaste/
  end

  def on_message(message, matches)
    doc = Nokogiri::HTML(http_get('http://www.toothpastefordinner.com/randomComicViewer.php'))
    img = doc.search('#comicarea img')
    link = doc.search('div.headertext a').first&.text.to_s
    [link.strip, img.first['src']]
  end
end
