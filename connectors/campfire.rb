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
      
      join_http = EventMachine::HttpRequest.new("#{@options["campfire_url"]}/room/#{@options["room"]}/join.xml").post request_options
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
      :auth => "#{@user["api_auth_token"]}:x",
      :timeout => 6
    }

    stream = Twitter::JSONStream.connect(options)

    stream.each_item do |item|
      process_message(item)
    end

    stream.on_error do |message|
      puts "ERROR:#{message.inspect}"
    end

    stream.on_max_reconnects do |timeout, retries|
      puts "Tried #{retries} times to connect."
      exit
    end
    
  end
  
  
  def process_message(item)
    message = JSON.parse(item)

    if message['type'] == 'TextMessage' && message['user_id'] != @user["id"]
      # Check if the user who is sending this message exists in the DB yet - if not, load the users details before
      # processing the message
      if Linkbot.user_exists?(message['user_id'])
        # Build the message
        message = Message.new( message['body'], message['user_id'], Linkbot.user_ids[message['user_id']], self, :message, {} )
        invoke_callbacks(message)
      else
        # Fetch the user data from campfire, then process the callbacks
        request_options = {
          :head => {
            'authorization' => [@user['api_auth_token'], "x"],
            'Content-Type' => 'application/json'
          }
        }

        user_http = EventMachine::HttpRequest.new("#{@options["campfire_url"]}/users/#{message['user_id']}.json").get request_options
        user_http.errback { puts "Yeah trouble entering the room." }
        user_http.callback {
          user = JSON.parse(user_http.response)["user"]
          Linkbot.add_user(user["name"],user["id"])
          message = Message.new( message['body'], message['user_id'], Linkbot.user_ids[message['user_id']], self, :message, {} )
          invoke_callbacks(message)
        }
      end
    end
  end

  def send_messages(messages,options = {})
    flattened_messages = []
    messages.each {|m| flattened_messages = flattened_messages + m.split("\n")}

    flattened_messages.each_with_index do |m,i|
      next if m.strip.empty?

      request_options = {
        :head => {
          'authorization' => [@user["api_auth_token"],"x"],
          'Content-Type' => 'application/json'
        },
        :body => {'message' => {'body' => m, 'type' => "TextMessage"}}.to_json
      }

      request = EventMachine::HttpRequest.new("#{@options["campfire_url"]}/room/#{@options['room']}/speak.json").post request_options
    end
  end
end
