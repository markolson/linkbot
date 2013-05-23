class Yes < Linkbot::Plugin

  def self.on_message(message, matches)
    case
    when message.user_name == "Jason Lewis" && message.body =~ /yes|yeah|yup|sure|/i
      "http://www.cleancutmedia.com/wp-content/uploads/2012/02/Cinemagraphs-Freaky.gif"
    when message.body =~ /h+e+l+l+(?:z|s)*\s*y+e*ah*/i
      self.hell_yeah
    when message.body =~ /si/i
      self.si
    when message.body =~ /m+h+m+/i
      self.mhm
    when message.body =~ /f+u+c+k+\s*y+e+a+h/
      self.fuck_yeah
    when message.body =~ /y+e+a+h+/i
      self.yyeeaahh
    when message.body =~ /sure/i
      self.sure
    when message.body =~ /Y+E+S+|!+/
      self.excited_yes
    else
      self.simple_yes
    end
  end

  Linkbot::Plugin.register('yes', self, {
    :message => {:regex => /(?:o+k+|y+e+s+|(?:(?:h+e+ll+(?:z*|s*)|f+u+c+k+)\s*)y+e*ah*|y+(?:u|e)+p+|y+a+|si|m+h+m+|(?:for\s)?sure)!*(?:\s+|\z)/i, :handler => :on_message}
  })

  private

  def self.excited_yes
    ["http://media.giphy.com/media/g4eOulPFxnIEE/200.gif", #fist pump
      "http://fc01.deviantart.net/fs70/f/2010/289/c/d/heck_yes_by_authorgreg-d30ucev.jpg", #heck yes
      "http://24.media.tumblr.com/tumblr_m6wkqu269Z1qihztbo1_500.gif", #oh yeah doctor who
      "http://media.giphy.com/media/10DfNV79muK3TO/200.gif", #sex and the city
      "http://media.giphy.com/media/bbot1PqAOPY4g/200.gif", #ari entourage
      "http://media.giphy.com/media/13fEclc7N0bshG/200.gif"
    ].sample
  end

  def self.yyeeaahh
    ["http://media.giphy.com/media/WrI5QcK7EtWog/200.gif", #rihanna
      "http://i42.photobucket.com/albums/e327/sniper7mm/lil_jon_yeah11.jpg", #Lil Jon
      "http://25.media.tumblr.com/73db98f98e39e0e69cd4311e81978fa5/tumblr_mexq983s7J1rhq9rvo1_500.gif"
      ].sample
  end

  def self.simple_yes
    ["http://media.giphy.com/media/14joII5lDkkVUc/200.gif", #amy poehler
      "http://media.giphy.com/media/127JeHZl15PRII/200.gif", #obviously
      "http://media.giphy.com/media/mlbdL8jYb2WOs/original.gif", #zack saved by the bell
      "http://www.reactiongifs.com/wp-content/gallery/yes/edward_scissorhands_yes.gif", #edward scissorhands
      "http://www.reactiongifs.com/wp-content/gallery/yes/stanley2.gif", #stanley the office
      "http://lh5.ggpht.com/_DVoNvgQORbw/TAi8_i66KyI/AAAAAAAAAds/53EJtFCbUGA/yes.gif" #star trek
    ].sample
  end

  def self.sure
    ["http://media.giphy.com/media/HFHovXXltzS7u/200.gif", #workaholics for sure
    ]
  end

  def self.si
    "http://cdn.memegenerator.net/instances/400x/37301541.jpg" #mexican man
  end

  def self.mhm
    "http://img.pandawhale.com/49063-beyonce-meme--mhm-I-know-thats-RHnp.gif" #beyonce
  end

  def hell_yeah
    ["http://www.frankottcountry.com/files/QuickSiteImages/Hell_Yeah_Transparent_9586.gif", #hell yeah in flames
      "http://www.scopecapemay.com/shop/252-526-large/can-i-get-a-hell-yeah-box-sign.jpg", #can i get a hell yeah
      "http://www.wwe24seven.com/images/105/stone-cold-steve-austin-wallpapers1.thumbnail.jpg" #stone cold
    ].sample
  end

  def self.fuck_yeah
    "http://yggdrasildistro.files.wordpress.com/2011/07/america-fuck-yeah-demotivational-poster-2.jpg" #america, fuck yeah
  end

end


