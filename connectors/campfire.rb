class Campfire < Linkbot::Connector
  Linkbot::Connector.register('campfire', self)

  def initialize(options)
    super(options)
        
    request_options = {
      :head => {
        'authorization' => [@options['username'], @options['password']],
        'Content-Type' => 'application/json' 
      }
    }
    
    user_http = EventMachine::HttpRequest.new("#{@options["campfire_url"]}/users/me.json").get request_options
    user_http.errback { puts "Yeah trouble logging in." }
    user_http.callback {
      @user = JSON.parse(user_http.response)["user"]
      request_options[:head]['authorization'] = [@user["api_auth_token"],"x"]
      request_options[:body] = "_"
      
      join_http = EventMachine::HttpRequest.new("#{@options["campfire_url"]}/#{@options["room"]}/join.xml").post request_options
      join_http.errback { puts "Yeah trouble entering the room." }
      join_http.callback {
        listen
      }
    }
  end


  def listen
    options = {
      :path => "/room/#{@options["room"]}/live.json",
      :host => "streaming.campfirenow.com",
      :auth => "#{@user["api_auth_token"]}:x"
    }

    stream = Twitter::JSONStream.connect(options)

    stream.each_item do |item|
      message = JSON.parse(item)
      return if message['user_id'] == @user["id"] || !message['user_id'] || !message['body'] || !message['type']
      
      # Check if the user who is sending this message exists in the DB yet - if not, load the users details before
      # processing the message
      if Linkbot.user_exists?(message['user_id'])
        # Build the message
        message = Message.new( message['body'], message['user_id'], Linkbot.user_ids[message['user_id']] )
        process_message(message)
      else
        # Fetch the user data from campfire, then process the callbacks
        request_options = {
          :head => {
            'authorization' => [@options['username'], @options['password']],
            'Content-Type' => 'application/json' 
          }
        }
        
        user_http = EventMachine::HttpRequest.new("#{@options["campfire_url"]}/users/#{message['user_id']}.json").get request_options
        user_http.errback { puts "Yeah trouble entering the room." }
        user_http.callback {
          user = JSON.parse(user_http.response)["user"]
          Linkbot.add_user(user["name"],user["id"])
          message = Message.new( message['body'], message['user_id'], Linkbot.user_ids[message['user_id']] )
          process_message(message)
        }
      end
    end

    stream.on_error do |message|
      puts "ERROR:#{message.inspect}"
    end

    stream.on_max_reconnects do |timeout, retries|
      puts "Tried #{retries} times to connect."
      exit
    end
    
  end
  

  def send_messages(messages)
    messages.each do |m|
      next if m.strip.empty?

      if m.include? "\n"
        return send_messages(m.split("\n"))
      end

      request_options = {
        :head => {
          'authorization' => [@options['username'], @options['password']],
          'Content-Type' => 'application/json'
        },
        :body => {'message' => {'body' => m, 'type' => "TextMessage"}}.to_json
      }
      
      message_http = EventMachine::HttpRequest.new("#{@options["campfire_url"]}/room/#{@options['room']}/speak.json").post request_options
      message_http.errback { puts "Yeah trouble with a message." }
      message_http.callback { puts "Message posted." }
      
      response = self.class.post("/room/#{Config["connectors"][0]["room"]}/speak.json", :body => j.to_json)

    end
  end
end