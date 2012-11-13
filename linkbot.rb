require 'rubygems'
require 'bundler/setup'

require 'twitter/json_stream'
require 'sanitize'
require 'htmlentities'
require 'eventmachine'
require 'em-http-request'
require 'json'
require 'httparty'
require 'rack'
require 'thin'

require 'pp'
require './config.rb'
require './util'
require './db'
require './plugin'
require './connector'

Linkbot::Config.load

### I DO NOT LIKE THIS
# But REXML is having some serious problems whenever a UTF-8 encoded string is received from hipchat.
# Sigh.
unless RUBY_VERSION < "1.9"
    # Encoding patch
    require 'socket'
    class TCPSocket
        def external_encoding
            Encoding::BINARY
        end
    end

    require 'rexml/source'
    class REXML::IOSource
        alias_method :encoding_assign, :encoding=
        def encoding=(value)
            encoding_assign(value) if value
        end
    end

    begin
        # OpenSSL is optional and can be missing
        require 'openssl'
        class OpenSSL::SSL::SSLSocket
            def external_encoding
                Encoding::BINARY
            end
        end
    rescue
    end
end

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
          # Check for broadcasts
          if message.connector.options["broadcast"]
            # Go through all of the connectors and send to all that accept broadcasts
            linkbot.connectors.each do |c|
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
