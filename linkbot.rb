require 'rubygems'
require 'httparty'

require 'json'
require 'pp'
require 'config.rb'

require 'base_plugins'
require 'base_dupe'

class Linkbot
  include HTTParty
  base_uri 'convore.com:443/api'
  basic_auth USER, PASS
  @@lastmsgs = {}

  def self.live
    get('/live.json')
  end

  def self.msg(topic, msg)
    response = post("/topics/#{topic}/messages/create.json", :body => {'message' => msg})
  end
  
  def self.monitor(topic)
    # reload our plugins
    Linkbot::Plugin.collect
    # get the list of messages from the api
    results = get("/topics/#{topic}/messages.json")
    # load just the messages into an array
    messages = JSON.load(results.body)['messages']
    messages.each { |m|
      sentat = m['date_created'].to_f
      # if the message is new, continue
      if(@@lastmsgs[topic] && @@lastmsgs[topic] < sentat)
        user = m['user']
        # if it wasn't sent by us, continue
        p "#{user['username']} == #{USER}"
        next if user['username'] == USER
        message = m['message']
        # try and match it against the plugins (method in plugins.rb)
        Linkbot::Plugin.match(user,message)
        #and dupes
        Linkbot::Dupe.check_dupe(user,message)
      end
    }
    #update our last time
    @@lastmsgs[topic] = messages.last['date_created'].to_f
  end
end

while true
  begin
    Linkbot.monitor(LINKCHAT)
    sleep(3)
  rescue Exception
    p $!
  end
end