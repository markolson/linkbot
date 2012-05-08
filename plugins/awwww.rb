class Awwww < Linkbot::Plugin
    Linkbot::Plugin.register('awwww', self,
      {
        :message => {:regex => /^a+w+$/i, :handler => :on_message}
      }
    )

    def self.on_message(message, matches)
      reddit = "http://www.reddit.com/r/aww.json"
      doc = ActiveSupport::JSON.decode(open(reddit).read)
      url = doc["data"]["children"][rand(doc["data"]["children"].length)]["data"]["url"]
      
      # Check if it's an imgur link without an image extension
      if url =~ /http:\/\/(www\.)?imgur\.com/ && !['jpg','png','gif'].include?(url.split('.').last)
        # Fetch the imgur page and pull out the image
        doc = Hpricot(open(url).read)
        url = doc.search("img")[1]['src']
        
        if ::Util.wallpaper?(url)
          url = [url, "(dealwithit) WALLPAPER WALLPAPER WALLPAPER (dealwithit)"]
        end
      end
      
      url
    end

end
