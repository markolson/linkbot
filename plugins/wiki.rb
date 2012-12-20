require 'rubygems'
require 'json'
require 'open-uri'
require 'cgi'

class Wiki < Linkbot::Plugin
  @@config = Linkbot::Config["plugins"]["hipchat"]

  if @@config
    Linkbot::Plugin.register('wiki', self,
      {
        :message => {:regex => Regexp.new('!wiki(?: (.+))'), :handler => :on_message, :help => :help}
      }
    )
  end

  def self.api_send(room, message)
    return if message.empty?

    token = @@config['api_token']

    begin
      url = "https://api.hipchat.com/v1/rooms/list?auth_token=#{token}"
      data = open(url).read
      puts data
      rooms = JSON.parse(data)["rooms"]
    rescue => e
      puts rooms
      puts e.inspect
      puts e.backtrace.join("\n")
    end

    room_id = rooms.find {|r| r["xmpp_jid"].start_with? room}["room_id"]
    puts "found room #{room_id} for room #{room}"

    message = CGI.escape(message)
    color = "gray"
    from = "wiki"
    raise "no api token" if !token
    begin
      url = "https://api.hipchat.com/v1/rooms/message?" \
          + "auth_token=#{token}&" \
          + "message_format=html&" \
          + "color=#{color}&" \
          + "room_id=#{room_id}&" \
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
    searchterm = CGI.escape(matches[0])
    searchresult = JSON.parse(open("https://en.wikipedia.org/w/api.php?action=query&list=search&srsearch=#{searchterm}&format=json").read)

    page = CGI.escape(searchresult["query"]["search"][0]["title"])
    doc = JSON.parse(open("http://en.wikipedia.org/w/api.php?format=json&action=parse&page=#{page}").read)

    text = doc["parse"]["text"]["*"]

    #killing all tables removes some spurious paragraphs
    text = text.gsub /<table.*?<\/table>/m, ''
    firstp = text[text.index('<p>')..text.index("</p>")]

    room = message[:options][:room] || "16485_link_bot_test_3"
    api_send(room, firstp)
    []
  end
end
