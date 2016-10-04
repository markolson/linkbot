class Awwww < Linkbot::Plugin

  def initialize
    register :regex => /^a+w+$/i
  end

  def on_message(message, matches)
    reddit = "https://www.reddit.com/r/aww.json"
    doc = ActiveSupport::JSON.decode(open(reddit, "User-Agent"=>"Linkbot").read)
    url = doc["data"]["children"][rand(doc["data"]["children"].length)]["data"]["url"]

    # Check if it's an imgur link without an image extension
    if url =~ /http:\/\/(www\.)?imgur\.com/ && !['jpg','png','gif'].include?(url.split('.').last)
      url += ".jpg"

      if wallpaper?(url)
        url = [url, "(dealwithit) WALLPAPER WALLPAPER WALLPAPER (dealwithit)"]
      end
    end

    url
  end

end
