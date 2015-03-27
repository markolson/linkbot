require 'slack'

class SlackConnector < Linkbot::Connector
  Linkbot::Connector.register('slack', self)

  def initialize(options)
    super(options)

    Slack.configure do |config|
      config.token = @options["token"]
    end

    puts "Creating slack client"
    @client = Slack.client

    puts "Connection realtime client"
    @rtc = @client.realtime

    puts "Client connected"
    @rtc.on :message do |data|
      if data["channel"]
        process_message(Time.at(data["ts"].to_i),data["user"],data["text"],{:room => data["channel"]})
      end
    end

    update_users(@client.post("rtm.start")["users"])

    @rtc.start
  end

  def update_users(users)
    puts "Updating users"
    users.each do |user|
      user_id = user["id"]
      if Linkbot.user_exists?(user_id)
        Linkbot.update_user(user["name"],user_id)
      else
        Linkbot.add_user(user["name"],user_id)
      end
    end
  end

  def process_message(time, nick, text, options={})
    if Linkbot.user_exists?(nick)
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
          :username => "Linkbot",
          :icon_url => "https://dl.dropboxusercontent.com/u/10931735/bot.png"
        })
      end
    end
  end
end
