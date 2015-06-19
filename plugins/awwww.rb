class Awwww < Linkbot::Plugin
    
    register :regex => /^a+w+$/i

    def self.on_message(message, matches)
      reddit = "http://www.reddit.com/r/aww.json"
      doc = ActiveSupport::JSON.decode(open(reddit).read)
      url = doc["data"]["children"][rand(doc["data"]["children"].length)]["data"]["url"]

      # Check if it's an imgur link without an image extension
      if url =~ /http:\/\/(www\.)?imgur\.com/ && !['jpg','png','gif'].include?(url.split('.').last)
        url += ".jpg"

        if ::Util.wallpaper?(url)
          url = [url, "(dealwithit) WALLPAPER WALLPAPER WALLPAPER (dealwithit)"]
        end
      end

      url
    end

end
