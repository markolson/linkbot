require 'em/pure_ruby'
require 'slack-ruby-client'
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
      Linkbot.log.info "Slack connector: Creating client"
      @client = Slack::Web::Client.new

      Linkbot.log.info "Slack connector: Connection realtime client"
      @rtc = Slack::RealTime::Client.new

      Linkbot.log.info "Slack connector: Client connected"
      @rtc.on :message do |data|
        if data["channel"]
          process_message(Time.at(data["ts"].to_i),data["user"],data["text"],{:room => data["channel"]})
        end
      end

      update_users(@client.post("rtm.start")["users"])

      @rtc.start!
    end

    def update_users(users)
      Linkbot.log.info "Slack connector: Updating users"
      users.each do |user|
        user_id = user["id"]
        if Linkbot.user_exists?(user_id)
          Linkbot.update_user(user["name"],user_id)
        else
          Linkbot.log.info "Slack connector: Adding #{user["name"]}"
          Linkbot.add_user(user["name"],user_id)
        end
      end
    end

    def process_message(time, nick, text, options={})
      if (!nick.nil? && nick != "")
        if !Linkbot.user_exists?(nick)
          update_users(@client.users_list["members"])
        end

        message = Message.new(text, nick, Linkbot.username(nick), self, :message, options )
        invoke_callbacks(message, options)
      end
    end

    def send_messages(messages, options={})
      messages.each do |message|
        if message && message.strip.length > 0
          @client.chat_postMessage({
            :channel => options[:room],
            :text => message,
            :username => @options["username"],
            :icon_url => @options["icon_url"],
          })
        end
      end
    end
  end
end
