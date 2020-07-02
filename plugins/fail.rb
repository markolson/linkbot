require 'open-uri'
require 'hpricot'

class Fail < Linkbot::Plugin
  include HTTParty

  def initialize
    register :regex => /^fail( .+)?/i
  end

  def on_message(message, matches)
    sound = true
    doc = Hpricot(open("https://www.failpictures.com").read)
    fail_image_paths = doc.search("img")
                          .map {|i| i.attributes['src'] }
                          .keep_if {|src| src.start_with? 'photos/' }
    "https://www.failpictures.com/" + fail_image_paths.sample
  end
end
