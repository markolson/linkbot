require 'open-uri'

class Fail < Linkbot::Plugin
  include HTTParty
    
  Linkbot::Plugin.register('fail', self, {
    :message => {:regex => /^fail( .+)?/i, :handler => :on_message}
  })

  def self.on_message(message, matches)
    sound = true
    url = "http://www.failpictures.com/index.php?module=ajax&action=ajax_init&cpaint_function=getimg&cpaint_response_type=JSON"
    doc = JSON.parse(open(url).read)
    
    if Linkbot::Config["plugins"]["fail"]["webhook"]
      get("#{Linkbot::Config["plugins"]["fail"]["webhook"]}")
    end
    
    doc["code"][0]["data"]
  end

end
