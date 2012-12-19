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

    message = CGI.escape(message)
    color = "gray"
    from = "wiki"
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
    searchterm = CGI.escape(matches[0])
    searchresult = JSON.parse(open("https://en.wikipedia.org/w/api.php?action=query&list=search&srsearch=#{searchterm}&format=json").read)
    page = CGI.escape(searchresult["query"]["search"][0]["title"])
    doc = JSON.parse(open("http://en.wikipedia.org/w/api.php?format=json&action=parse&page=#{page}").read)
    text = doc["parse"]["text"]["*"]
    room = message[:options][:room] || "link_bot_test_3"
    firstp = text[text.index('<p>')..text.index("</p>")]
    api_send(room.split('_', 2)[1], firstp)
    []
  end
end
