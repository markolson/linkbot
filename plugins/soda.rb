require 'open-uri'
require 'hpricot'

class Soda < Linkbot::Plugin

  def self.help
    "!soda - get a gif from /r/wheredidthesodago"
  end

  create_log(:images)

  def self.on_message(message, matches)
    url = "http://reddit.com/r/wheredidthesodago.json"

    doc = ActiveSupport::JSON.decode(open(url).read)

    #reject anything with nsfw in the title
    doc = doc["data"]["children"].reject {|x| x["data"]["title"] =~ /nsfw/i || x["data"]["over_18"]}

    return "XXX FIAL XXX" if doc.empty?

    randdoc = rand(doc.length)
    url = doc[randdoc]["data"]["url"]
    title = doc[randdoc]["data"]["title"]

    # Check if it's an imgur link without an image extension
    if url =~ /http:\/\/(www\.)?imgur\.com/ && !['jpg','png','gif'].include?(url.split('.').last)
      url += ".gif"
    end

    log(:images, url)

    [title, url]
  end

  Linkbot::Plugin.register('soda', self, {
    :message => {:regex => /!soda/i, :handler => :on_message, :help => :help}
  })
end
