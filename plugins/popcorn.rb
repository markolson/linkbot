class Popcorn < Linkbot::Plugin
  
  register :regex => /!popcorn/
  help "!popcorn - Everyone loves popcorn"

    def self.on_message(message, matches)
      quotes = ['http://i.imgur.com/qlRu3.gif',
                'http://i.imgur.com/DDMBW.gif',
                'http://i.imgur.com/SbyLU.gif',
                'http://i.imgur.com/y8F8s.gif',
                'http://i.imgur.com/lozGr.gif',
                'http://i.imgur.com/YG6vv.gif',
                'http://i.imgur.com/IUoJx.gif',
                'http://i.imgur.com/lae9h.gif',
                'http://www.strangecosmos.com/images/content/167278.gif',
                'http://i.imgur.com/enRL0.gif',
                'http://i.imgur.com/QfkRE.gif',
                'http://i.imgur.com/kXfy9.gif',
                'http://i.imgur.com/ZDdhJ.gif',
                'http://www.threadbombing.com/data/media/2/scarjo_popcorn.gif'
	]
      quotes[rand(quotes.length)]
    end

end
