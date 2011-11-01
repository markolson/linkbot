class Success < Linkbot::Plugin
    @@success_regex = Regexp.new(/^!success?[ ](.*)?[;][ ](.*)?$/)

    def self.on_message(message, matches)
      
      lines = message.body.scan(@@success_regex)
      
      if lines[0] && lines[0].count == 2
	
	url = URI.parse 'http://memegenerator.net/create/instance'
        res, location = nil, nil

    	post_data = {
	  "generatorID" => 121,
	  "imageID" => 1031,
	  "text0" => lines[0][0],
	  "text1" => lines[0][1],
	  "languageCode" => "en"
    	}

    	Net::HTTP.start url.host do |http|
      	  post = Net::HTTP::Post.new url.path
      	  #post['User-Agent'] = USER_AGENT
      	  post.set_form_data post_data

      	  res = http.request post

      	  id = res['Location'].split('/').last.to_i
	  return "http://images.memegenerator.net/instances/400x/#{id}.jpg"
    	end
      end
      
      #No text provided... send generic success kid image
      "http://i.imgur.com/vQr7I.png"
    end
    
    Linkbot::Plugin.register('success', self,
      {
        :message => {:regex => /!success(.*)/, :handler => :on_message}
      }
    )
end


