require 'async'
require 'async/io'
require 'async/io/ssl_endpoint'
require 'async/websocket/client'
require 'slack-ruby-client'
require 'json'
require 'net/http'
require 'openssl'

module Linkbot
  class SlackConnector < Linkbot::Connector
    Linkbot::Connector.register('slack', self)

    def initialize(options)
      super(options)
      @options["username"] ||= "Linkbot"
      @options["icon_url"] ||= "https://dl.dropboxusercontent.com/u/10931735/bot.png"

      Slack.configure do |config|
        config.token = @options["token"]
      end
    end

    def start
      Linkbot.log.info "Slack connector: Creating web client"
      @client = Slack::Web::Client.new

      update_users(@client.users_list["members"])

      Linkbot.log.info "Slack connector: Starting Socket Mode"
      Thread.new { run_socket_mode }
    end

    def update_users(users)
      Linkbot.log.info "Slack connector: Updating users"
      users.each do |user|
        user_id = user["id"]
        if Linkbot.user_exists?(user_id)
          Linkbot.update_user(user["name"], user_id)
        else
          Linkbot.log.info "Slack connector: Adding #{user["name"]}"
          Linkbot.add_user(user["name"], user_id)
        end
      end
    end

    def process_message(time, nick, text, options={})
      return if nick.nil? || nick.empty?

      unless Linkbot.user_exists?(nick)
        update_users(@client.users_list["members"])
      end

      message = Message.new(text, nick, Linkbot.username(nick), self, :message, options)
      EventMachine.schedule { invoke_callbacks(message, options) }
    end

    def send_messages(messages, options={})
      messages.each do |message|
        next unless message && message.strip.length > 0
        @client.chat_postMessage(
          channel: options[:room],
          text: message,
          username: @options["username"],
          icon_url: @options["icon_url"],
          thread_ts: options[:thread_ts]
        )
      end
    end

    private

    def get_socket_url
      uri = URI('https://slack.com/api/apps.connections.open')
      req = Net::HTTP::Post.new(uri)
      req['Authorization'] = "Bearer #{@options["app_token"]}"
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |http| http.request(req) }
      data = JSON.parse(response.body)
      raise "apps.connections.open failed: #{data["error"]}" unless data["ok"]
      data["url"]
    end

    def run_socket_mode
      loop do
        url = get_socket_url
        Linkbot.log.info "Slack connector: Connecting via Socket Mode"

        Async do
          connect_and_handle(url)
        end

        Linkbot.log.warn "Slack connector: Disconnected, reconnecting..."
        sleep 1
      rescue => e
        Linkbot.log.error "Slack connector error: #{e.message}"
        sleep 5
      end
    end

    def connect_and_handle(url_str)
      uri = URI.parse(url_str)
      host = uri.host
      port = uri.port || 443

      tcp = Async::IO::Endpoint.tcp(host, port)
      ssl_context = OpenSSL::SSL::SSLContext.new(:TLSv1_2_client)
      ssl_context.set_params(verify_mode: OpenSSL::SSL::VERIFY_PEER)
      endpoint = Async::IO::SSLEndpoint.new(tcp, ssl_context: ssl_context)

      socket = endpoint.connect
      connection = Async::WebSocket::Client.new(socket, url_str)

      while message = connection.next_message
        handle_socket_message(connection, message)
      end
    rescue => e
      Linkbot.log.error "Slack WebSocket error: #{e.message}"
    end

    def handle_socket_message(connection, data)
      if data["envelope_id"]
        connection.send_message({ "envelope_id" => data["envelope_id"] })
      end

      case data["type"]
      when "hello"
        Linkbot.log.info "Slack connector: Socket Mode connected"
      when "disconnect"
        Linkbot.log.warn "Slack connector: Server requested disconnect"
        connection.close
      when "events_api"
        event = data.dig("payload", "event")
        return unless event && event["type"] == "message" && event["channel"]
        return if event["bot_id"] || event["subtype"]

        process_message(
          Time.at(event["ts"].to_f),
          event["user"],
          event["text"],
          { room: event["channel"], thread_ts: event["thread_ts"] }
        )
      end
    end
  end
end
