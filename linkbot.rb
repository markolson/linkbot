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

  def initialize
    Linkbot::Plugin.collect
    #{"user":{"type":"Member",
    #         "created_at":"2011/10/17 18:14:21 +0000",
    #         "avatar_url":"http://asset0.37img.com/global/missing/avatar.png?r=3",
    #         "id":1031898,
    #         "admin":false,
    #         "name":"Linkbot McGee",
    #         "email_address":"bill.mill+linkbot@gmail.com",
    #         "api_auth_token":"db8b174571365a8e638528f8eca5e43ca6860b26"}}
    @my_user = JSON.load(self.class.get("/users/me.json").body)["user"]
    self.class.basic_auth @my_user["api_auth_token"], "x"
    
    joinroom = "/room/#{ROOM_ID}/join.xml"
    response = self.class.post(joinroom, :body => "_")

    if response.response.code != "200"
      raise "Unable to join room #{joinroom}, got #{response.response}"
    end
  end

  def my_user
    @my_user
  end

  def process(message)
    message = JSON.parse(message)
    return if message["type"] != "TextMessage"

    #DELETEME
    pp message
    
    # if it wasn't sent by us, continue
    return if message['user_id'] == @my_user["id"]

    # Create the user's info, if it does not exist
    rows = Linkbot.db.execute("select * from users where user_id = '#{message['user_id']}'")
    if rows.empty?
      user = JSON.parse(self.class.get("/users/#{message['user_id']}.json").body)["user"]
      Linkbot.db.execute("insert into users (user_id,username) values ('#{user['id']}', '#{user['name']}')")
    end

    # Handle the message
    Linkbot::Plugin.handle_message(user, m)
  end

  def self.msg(url, msg)
    # Convert break tags to newlines
    msg.gsub!(/\<br\w*\/?\w*\>/, "\n")
    
    # Decode HTML entities
    coder = HTMLEntities.new
    msg = coder.decode(msg)
    
    # Sanitize the HTML
    msg = Sanitize.clean(msg)
    
    response = post(url, :body => {'message' => msg})
  end
end

linkbot = Linkbot.new

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
