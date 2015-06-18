require 'open-uri'
require 'hpricot'

class Fail < Linkbot::Plugin
  include HTTParty

  register :regex => /^fail( .+)?/i

  def self.on_message(message, matches)
    sound = true
    doc = Hpricot(open("http://www.failpictures.com").read)
    img = "http://www.failpictures.com/" + doc.search("img[@alt='following next photo']").first.attributes['src']

    if Linkbot::Config["plugins"]["fail"]["webhook"]
      get("#{Linkbot::Config["plugins"]["fail"]["webhook"]}")
    end

    img
  end

end
