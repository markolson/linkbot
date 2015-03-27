#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

require 'sanitize'
require 'htmlentities'
require 'eventmachine'
require 'em-http-request'
require 'json'
require 'httparty'
require 'rack'
require 'thin'

require 'pp'
require_relative 'config'
require_relative 'util'
require_relative 'db'
require_relative 'plugin'
require_relative 'connector'

Linkbot::Config.load

# I'm just stabbing at this point
Encoding.default_internal = Encoding.default_external = "UTF-8"

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
      connector.onmessage do |message,options|
        EventMachine::defer(proc {
          messages = Linkbot::Plugin.handle_message(message)
          message.connector.send_messages(messages,options)
        })
      end
    end

    #every 30 seconds, run periodic plugins
    EventMachine.add_periodic_timer(30) do
      linkbot.connectors.each do |c|
        begin
          c.periodic
        rescue Exception => e
          puts "error in call to #{c}"
          puts e
        end
      end
    end
  end
end
