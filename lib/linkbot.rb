#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'

$LOAD_PATH.unshift "#{File.dirname(__FILE__)}/linkbot"
require 'config'
require 'db'
require 'plugin'
require 'connector'

module Linkbot
  class Bot
    attr_accessor :connectors

    def initialize(options)
      Linkbot::Config.load(options[:config_path])

      if options[:console]
        Linkbot::Config["connectors"] = [{ "type" => "console", "periodic" => true, "receive_broadcasts" => true}]
      end

      @connectors = []
      Linkbot::Connector.collect
      Linkbot.load_users
      Linkbot::Plugin.collect(Linkbot::Config["extra_plugin_directories"])
    end

    def run
      EventMachine::run do
        Linkbot::Config["connectors"].each { |config| 
          if Linkbot::Connector[config["type"]]
            connectors << Linkbot::Connector[config["type"]].new(config)
          end
        }

        connectors.each do |connector|
          connector.onmessage do |message,options|
            EventMachine::defer(proc {
              messages = Linkbot::Plugin.handle_message(message)
              # Check for broadcasts
              if message.connector.options["broadcast"]
                # Go through all of the connectors and send to all that accept broadcasts
                connectors.each do |c|
                  if c.options["receive_broadcasts"]
                    begin
                      c.send_messages(messages)
                    rescue => e
                      end_msg = "the #{c} connector threw an exception: #{e.inspect}"
                      puts e.inspect
                      puts e.backtrace.join("\n")
                    end
                  end
                end
              else
                message.connector.send_messages(messages,options)
              end
            })
          end
          connector.start
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
  end
end
