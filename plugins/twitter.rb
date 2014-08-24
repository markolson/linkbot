require 'open-uri'
require 'hpricot'

class Twitter < Linkbot::Plugin
  Linkbot::Plugin.register('twitter', self, {
    :message => {:regex => /(https:\/\/twitter.com\/[\w\/]*)/, :handler => :on_message}
  })

  def self.on_message(message, matches)
    puts "----------------------* herererererr *-------------------"
    url = matches[0]
    doc = Hpricot(open(url).read)
    doc.at(".tweet-text").inner_text
  end
end
