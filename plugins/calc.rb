require 'open-uri'
require 'cgi'

class Calc < Linkbot::Plugin
  @@config = Linkbot::Config["plugins"]["hipchat"]

  if @@config
    Linkbot::Plugin.register('calc', self, {
      :message => {:regex => /!calc (.+)/i, :handler => :on_message}
    })
  end

  def self.api_send(room, message)
    return if message.empty?

    message = CGI.escape(message)
    color = "gray"
    from = "calc"
    token = @@config['api_token']
    raise "no api token" if !token
    begin
      url = "https://api.hipchat.com/v1/rooms/message?" \
          + "auth_token=#{token}&" \
          + "message_format=html&" \
          + "color=#{color}&" \
          + "room_id=#{room}&" \
          + "from=#{from}&" \
          + "message=#{message}"

          puts "sending hipchat messaage to #{url}"
      open(url)
    rescue => e
      puts e.inspect
      puts e.backtrace.join("\n")
    end
  end

  def self.on_message(message, matches)
    query = CGI.escape(matches[0])
    url = "https://encrypted.google.com/search?hl=en&q=#{query}"
    doc = Hpricot(open(url).read)

    begin
      answer = (doc/'h2').find {|x| x.attributes["class"] == 'r'}.html
    rescue NoMethodError
      return ["unable to calculate #{matches[0]}"]
    end

    #hipchat doesn't support <sup>
    answer.gsub! /<sup>/, '^'
    answer.gsub! /<\/sup>/, ''

    room = message[:options][:room] || "16485_link_bot_test_3"
    room = room.split('_', 2)[1]
    self.api_send room, answer
    []
  end
end
