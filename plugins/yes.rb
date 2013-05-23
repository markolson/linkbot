class Yes < Linkbot::Plugin

  def self.on_message(message, matches)
    case
    when message.body.scan(/n+o+/i).count > 1
      self.lots_of_nos
    when message.body.match(/n+o+!/i)
      self.emphatic_no
    when message.body.match(/noo+/i)
      self.emphatic_no
    else
      self.simple_no
    end
  end

  Linkbot::Plugin.register('yes', self, {
    :message => {:regex => /^(?:y+e+s+|(?:h+e+ll+z*\w*)y+e*ah*|y+(?:u|e)+p+|y+a+|si|ja|fuck\syeah|m+h+m+|(?:for\s)?sure)!*$/i, :handler => :on_message}
  })

  private

  def self.lots_of_yes
    %w( http://i.imgur.com/Rd8xu.gif
        http://i.imgur.com/XWAvo.gif
        http://i.imgur.com/816uC.gif
        http://media.tumblr.com/tumblr_lvpj1lEg5N1qegw8v.gif
        http://media.tumblr.com/tumblr_m42alaqSHG1rom4w3.gif
        http://media.tumblr.com/tumblr_m4ybpoVu2L1qhk160.gif
        http://media.tumblr.com/tumblr_m9t9sot19G1r1qmov.gif
      ).sample
  end

  def self.emphatic_yes
    ["http://media.giphy.com/media/g4eOulPFxnIEE/200.gif",
      "http://fc01.deviantart.net/fs70/f/2010/289/c/d/heck_yes_by_authorgreg-d30ucev.jpg",
      "http://24.media.tumblr.com/tumblr_m6wkqu269Z1qihztbo1_500.gif",
    ].sample
  end

  def self.simple_yes
    ["http://media.giphy.com/media/14joII5lDkkVUc/200.gif",
      "http://media.giphy.com/media/127JeHZl15PRII/200.gif"
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
    ["http://cdn.memegenerator.net/instances/400x/30955267.jpg"

      ].sample
  end

  def hell_yeah
    ["http://www.frankottcountry.com/files/QuickSiteImages/Hell_Yeah_Transparent_9586.gif", #hell yeah in flames
      "http://www.scopecapemay.com/shop/252-526-large/can-i-get-a-hell-yeah-box-sign.jpg", #can i get a hell yeah
    ].sample
  end

  def self.fuck_yeah
    "http://yggdrasildistro.files.wordpress.com/2011/07/america-fuck-yeah-demotivational-poster-2.jpg" #america, fuck yeah
  end

end

