require 'rubygems'
require 'bundler/setup'

require 'twitter/json_stream'
require 'sanitize'
require 'htmlentities'
require 'eventmachine'
require 'em-http-request'
require 'json'

require 'pp'
require 'config.rb'
require 'util'
require 'db'
require 'plugin'
require 'connector'

Linkbot::Config.load

module Linkbot
  class Bot
    attr_accessor :connectors

    def initialize
      Linkbot::Config.load
      Linkbot::Plugin.collect
      Linkbot::Connector.collect
      Linkbot.load_users
      @connectors = []
    end
  end 
end


if __FILE__ == $0
  linkbot = Linkbot::Bot.new
  
  EventMachine::run do
    Linkbot::Config["connectors"].each { |config| linkbot.connectors << Linkbot::Connector[config["type"]].new(config) if Linkbot::Connector[config["type"]] }
    
    linkbot.connectors.each do |connector| 
      connector.onmessage do |message|
        EventMachine::defer(proc {
          messages = Linkbot::Plugin.handle_message(message)
          message.connector.send_messages(messages)
        })
      end
    end
  end
end
