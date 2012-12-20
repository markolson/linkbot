require 'rubygems'
require 'json'
require 'open-uri'
require 'cgi'
require 'hpricot'

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

      open(url)
    rescue => e
      puts e.inspect
      puts e.backtrace.join("\n")
    end
  end

  def self.on_message(message, matches)
    searchterm = CGI.escape(matches[0])
    searchresult = JSON.parse(open("https://en.wikipedia.org/w/api.php?action=query&list=search&srsearch=#{searchterm}&format=json").read)

    pages = searchresult["query"]["search"]

    #try to reject disambiguation pages
    pages.reject! {|p| p["snippet"].index("may refer to") != nil}

    if pages.empty?
      return ["Unable to find wiki page for #{matches[0]}"]
    end

    page = CGI.escape(pages[0]["title"])
    doc = JSON.parse(open("http://en.wikipedia.org/w/api.php?format=json&action=parse&page=#{page}").read)
    doc = Hpricot(doc["parse"]["text"]["*"])

    #killing all tables removes much of the text we don't want
    (doc/"table").remove

    #only grab text in paragraphs
    grafs = (doc/"p")

    #reject coordinate grafs, like Hawaii. Place further rules to eliminate spurious first paragraphs below this.
    grafs.reject! {|g| g.to_s.index("Geographic_coordinate_system") }

    text = grafs[0].to_s

    #make the links valid
    text.gsub! /href="(.[^\/])/, 'href="http://en.wikipedia.org\1'

    #now truncate to 9000 chars hard limit (hipchat says 10k but seems to lie)
    text = text[0..9000]

    room = message[:options][:room] || "16485_link_bot_test_3"
    api_send(room, text)
    ["http://en.wikipedia.org/wiki/#{page}"]
  end
end
