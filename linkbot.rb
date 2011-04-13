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

  def self.live
    cursor = nil
    while true
      begin
        Linkbot::Plugin.collect

        options = cursor.nil? ? {} : {'cursor' => cursor}
        puts "requesting"
        results = get('/live.json', options)

        messages = JSON.load(results.body)['messages']
        messages.each do |m|
          cursor = m["_id"]

          # if it wasn't sent by us, continue
          user = m['user']
          next if user['username'] == USER

          #ignore some verbose messages
          if !(['login', 'logout', 'read'].include? m['kind'])
            puts m
          end

          # try and match it against the plugins (method in plugins.rb)
          Linkbot::Plugin.match(user, m)
          #and dupes
          Linkbot::Dupe.check_dupe(user, m)
        end

      #unless it's an interrupt (i.e. ^C),
      rescue Interrupt
        exit
      #catch it and keep on truckin
      rescue Exception
        #TODO: just put that exception
        puts $!
        puts $!.backtrace.join "\n"
      end
    end
  end

  def self.msg(topic, msg)
    response = post("/topics/#{topic}/messages/create.json", :body => {'message' => msg})
  end
end

Linkbot.live
