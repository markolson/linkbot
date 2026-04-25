require 'nokogiri'

class Twitter < Linkbot::Plugin

  def initialize
    @config  = Linkbot::Config["plugins"]["twitter"]
    # Set the following in config.json to have linkbot retrieve and display
    # tweet content for chat services that don't do that already.
    # { "plugins": {
    #     "twitter": {
    #       "expand_content": true
    #     }
    #   }
    # }
    if @config && @config["expand_content"]
      register :regex => /(https:\/\/twitter.com\/[\w\/]*)/
    end
  end

  def on_message(message, matches)
    url = matches[0]
    doc = Nokogiri::HTML(http_get(url))
    msg = doc.at(".opened-tweet .tweet-text").text

    # images we want to display have a "src" and match pbs.twimg.com/media
    images = doc.search("img").select {|x| x["src"]&.match(/pbs.twimg.com\/media/) }
    if images.length > 0
      src = images.first["src"]
      # strip trailing :large
      src.gsub! /:large$/, ''

      msg = "#{msg} #{src}"
    end

    msg
  end
end
