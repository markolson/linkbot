class Toothpaste < Linkbot::Plugin
    Linkbot::Plugin.register('toothpaste', self,
      {
        :message => {:regex => /!toothpaste/, :handler => :on_message}
      }
    )

    def self.on_message(message, matches)
        doc = Hpricot(open('http://www.toothpastefordinner.com/randomComicViewer.php'))
        img = doc.search('#comicarea img')
        link = doc.search('div.headertext a:first').text()
        "#{link.strip}\n#{img.first['src']}"
    end
end

