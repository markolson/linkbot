require 'rubygems'

#gem install twitter-stream -s http://gemcutter.org
require 'twitter/json_stream'

require 'httparty'

require 'sanitize'
require 'htmlentities'

require 'json'
require 'pp'
require 'config.rb'

require 'util'
require 'db'
require 'base_plugins'

class Linkbot
  include HTTParty
  base_uri BASE_URI
  basic_auth USER, PASS
  headers 'Content-Type' => 'application/json' 
  debug_output $stderr

  attr_accessor :my_user

  def initialize
    Linkbot::Plugin.collect
    
    @typemap = {
      "TextMessage" => MessageType::MESSAGE,
      #stars don't seem to show up in the livestream?
      #handle DMs
    }

    #load all users' names
    rows = Linkbot.db.execute("select user_id, username from users")
    #map ids to names (both as strings)
    @user_ids = Hash[rows]
    #map names ids
    @users = Hash[rows.collect {|a,b| [b,a]}]
  end

  def login
    @my_user = JSON.load(self.class.get("/users/me.json").body)["user"]
    self.class.basic_auth @my_user["api_auth_token"], "x"
    
    joinroom = "/room/#{ROOM_ID}/join.xml"
    response = self.class.post(joinroom, :body => "_")

    if response.response.code != "200"
      raise "Unable to join room #{joinroom}, got #{response.response}"
    end
  end

  def process(message)
    EventMachine::defer(proc {
      message = JSON.parse(message)

      #DELETEME
      puts "processing:\n"
      pp message
      #DELETEME

      return if message['user_id'] == @my_user["id"]

      #for now, just discard all non-messages. TODO: what else should we accept, and how?
      return if !message['user_id'] || !message['body'] || !message['type']

      type = @typemap[message["type"]]

      raise "Unknown Message Type #{message["type"]}" if not type

      # Create the user's info, if it does not exist
      rows = Linkbot.db.execute("select * from users where user_id = '#{message['user_id']}'")
      if rows.empty?
        user = JSON.parse(self.class.get("/users/#{message['user_id']}.json").body)["user"]
        Linkbot.db.execute("insert into users (user_id,username) values ('#{user['id']}', '#{user['name']}')")

        #update our user hashes
        @user_ids[user['id']] = user['name']
        @users[user['name']] = user['id']
      end

      message = Message.new(message['body'],
                            message['user_id'],
                            @user_ids[message['user_id']],
                            type)

      # Handle the message
      messages = Linkbot::Plugin.handle_message(message)
      send_messages(messages)
    })
  end

  def send_messages(messages)
    messages.each do |m|
      next if m.strip.empty?

      if m.include? "\n"
        return send_messages(m.split("\n"))
      end

      j = {
        'message' => {
          'body' => m,
          'type' => "TextMessage",
        }
      }

      response = self.class.post("/room/#{ROOM_ID}/speak.json", :body => j.to_json)

      if response.response.code != "201"
        raise "Unable to send message #{m}, got #{response.response}"
      end
    end
  end
end

if __FILE__ == $0

  linkbot = Linkbot.new
  linkbot.login

  options = {
    :path => "/room/#{ROOM_ID}/live.json",
    :host => "streaming.campfirenow.com",
    :auth => "#{linkbot.my_user['api_auth_token']}:x"
  }

  EventMachine::run do
    stream = Twitter::JSONStream.connect(options)

    stream.each_item do |item|
      linkbot.process item
    end
   
    stream.on_error do |message|
      puts "ERROR:#{message.inspect}"
    end
   
    stream.on_max_reconnects do |timeout, retries|
      puts "Tried #{retries} times to connect."
      exit
    end
  end
end
