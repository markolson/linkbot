class Meh < Linkbot::Plugin

  def self.on_message(message, matches)
    mehs = ["http://farm5.staticflickr.com/4122/4869449359_1576cf6d18_m.jpg",
            "http://gal.darkervision.com/wp-content/uploads/2008/11/meh_small.jpg",
            "http://i.zdnet.com/blogs/meh.jpg",
            "http://cache.gawker.com/assets/images/7/2008/11/meh_cat.jpg"]
    mehs[rand(mehs.size)]
  end

  Linkbot::Plugin.register('meh', self, {
    :message => {:regex => /^meh|.*[ ]meh([ ].*)?$/i, :handler => :on_message}
  })
end
