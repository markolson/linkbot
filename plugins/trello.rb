class Trello < Linkbot::Plugin
  @@config = Linkbot::Config["plugins"]["trello"]

  if @@config
    Linkbot::Plugin.register('trello', self, {
      :periodic => {:handler => :periodic}
    })

    if Linkbot.db.table_info('trello').empty?
      Linkbot.db.execute('CREATE TABLE trello (dt TEXT)');
    end
  end

  def self.api_send(message)
    puts "message is:"
    pp message
    message = CGI.escape(message)
    color = @@config['hipchat_color'] || "purple"
    from = @@config['hipchat_from'] || "trello"
    begin
      open("https://api.hipchat.com/v1/rooms/message?" \
          +"auth_token=#{@@config['hipchat_api_token']}&" \
          +"message=#{message}&" \
          +"color=#{color}&" \
          +"room_id=#{@@config['hipchat_room']}&" \
          +"from=#{from}")
    rescue => e
      puts e.inspect
      puts e.backtrace.join("\n")
    end
  end

  def self.process_item(item)
    user = item["memberCreator"]["fullName"]

    dispatch = {
      "commentCard" => Proc.new{ |item|
        card = item["data"]["card"]["name"]
        board = item["data"]["board"]["id"]
        cardid = item["data"]["card"]["id"]
        "#{user} commented on card <a href=\"http://trello.com/card/#{board}/#{cardid}\">#{card}</a>"
      },
      "updateCard" => Proc.new{ |item|
        card = item["data"]["card"]["name"]
        board = item["data"]["board"]["id"]
        cardid = item["data"]["card"]["id"]
        "#{user} updated card <a href=\"http://trello.com/card/#{board}/#{cardid}\">#{card}</a>"
      },
      "createCard" => Proc.new{ |item|
        card = item["data"]["card"]["name"]
        board = item["data"]["board"]["id"]
        cardid = item["data"]["card"]["id"]
        "#{user} created card <a href=\"http://trello.com/card/#{board}/#{cardid}\">#{card}</a>"
      },
      "createList" => Proc.new{ |item|
        list = item["data"]["list"]["name"]
        board = item["data"]["board"]["id"]
        "#{user} created list <a href=\"http://trello.com/board/#{board}\">#{list}</a>"
      },
    }

    msgtype = item["type"]
    dispatch.has_key?(msgtype) ? (dispatch[msgtype]).call(item) : ""
  end

  def self.periodic
    #by default, grab all entries since one day ago
    min_pull = Time.now.utc - 60*60*24

    rows = Linkbot.db.execute("select dt from trello")
    min_pull = Time.parse(rows[0][0]) if !rows.empty? && rows[0][0]

    messages = []

    max_item_time = min_pull
    
    # need to increment a second so that we don't pull up dupes
    since_time = (min_pull + 1).strftime '%Y-%m-%dT%H:%M:%S'

    #TODO: need to add board config support
    board = "4fda1dbcf2f3123b180e0f09"
    url = "https://trello.com/1/boards/#{board}/actions?" \
          "key=#{@@config['key']}&" \
          "token=#{@@config['token']}&" \
          "limit=10&" \
          "since=#{since_time}"

    puts "requesting #{url}"
    begin
      items = ActiveSupport::JSON.decode(open(url).read)
    rescue SocketError => e
      puts "could not retrieve #{url}"
      return {:messages => [], :options => {}}
    end

    items.reverse.each do |item|
      item_time = Time.parse(item["date"])
      puts item_time

      message = self.process_item(item)
      self.api_send(message)

      if item_time > max_item_time
        max_item_time = item_time
      end
    end

    Linkbot.db.execute("delete from trello")
    Linkbot.db.execute("insert into trello (dt) VALUES ('#{max_item_time}')")

    {:messages => messages, :options => {:room => @@config['room']}}
  end
end
