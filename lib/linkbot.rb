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
      Linkbot.load_users
      Linkbot::Connector.collect
      load_connectors

      plugin_paths = []
      if Linkbot::Config.has_key? "extra_plugin_directories"
        Linkbot::Config["extra_plugin_directories"].each {|p| plugin_paths << p}
      end
      plugin_paths << File.expand_path(File.join(File.dirname(__FILE__), "..", "plugins"))
      Linkbot::Plugin.collect(plugin_paths)
    end


    def load_connectors
      Linkbot::Config["connectors"].each { |config| 
        if Linkbot::Connector[config["type"]]
          connector =  Linkbot::Connector[config["type"]].new(config)
          connector.onmessage do |message,options|
            EventMachine::defer(proc { 
              messages = Linkbot::Plugin.handle_message(message)
              message.connector.send_messages(messages,options)
            })
          end
          connectors << connector
        end
      }
    end

    def run_periodically_too
      #every 30 seconds, run periodic plugins
      EventMachine.add_periodic_timer(30) do
        connectors.each do |c|
          begin
            c.periodic
          rescue Exception => e
            puts "error in call to #{c}"
            puts e
          end
        end
      end
    end

    def run
      EventMachine::run { connectors.each(&:start) }
      run_periodically_too
    end
  end
end
