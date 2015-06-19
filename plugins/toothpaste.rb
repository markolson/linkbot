class Toothpaste < Linkbot::Plugin
    register :regex => /!toothpaste/

    def self.on_message(message, matches)
        doc = Hpricot(open('http://www.toothpastefordinner.com/randomComicViewer.php'))
        img = doc.search('#comicarea img')
        link = doc.search('div.headertext a:first').text()
        [link.strip, img.first['src']]
    end
end
