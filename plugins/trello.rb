class Trello < Linkbot::Plugin
  @@config = Linkbot::Config["plugins"]["trello"]

  if @@config

    register :periodic => {:handler => :periodic}
    
    if Linkbot.db.table_info('trello').empty?
      Linkbot.db.execute('CREATE TABLE trello (dt TEXT)');
    end
  end

  def self.api_send(message)
    return if message.empty?

    message = CGI.escape(message)
    color = @@config['hipchat_color'] || "purple"
    from = @@config['hipchat_from'] || "Trello"
    begin
      url = "https://api.hipchat.com/v1/rooms/message?" \
          + "auth_token=#{@@config['hipchat_api_token']}&" \
          + "message=#{message}&" \
          + "color=#{color}&" \
          + "room_id=#{@@config['hipchat_room']}&" \
          + "from=#{from}"

      open(url)
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
        boardname = item["data"]["board"]["name"]
        cardid = item["data"]["card"]["id"]
        "#{user} commented on card <a href=\"http://trello.com/card/#{board}/#{cardid}\">#{card}</a> on #{boardname}"
      },
      "updateCard" => Proc.new{ |item|
        card = item["data"]["card"]["name"]
        board = item["data"]["board"]["id"]
        boardname = item["data"]["board"]["name"]
        cardid = item["data"]["card"]["id"]
        "#{user} updated card <a href=\"http://trello.com/card/#{board}/#{cardid}\">#{card}</a> on #{boardname}"
      },
      "createCard" => Proc.new{ |item|
        card = item["data"]["card"]["name"]
        board = item["data"]["board"]["id"]
        cardid = item["data"]["card"]["id"]
        boardname = item["data"]["board"]["name"]
        "#{user} created card <a href=\"http://trello.com/card/#{board}/#{cardid}\">#{card}</a> on #{boardname}"
      },
      "createList" => Proc.new{ |item|
        list = item["data"]["list"]["name"]
        board = item["data"]["board"]["id"]
        boardname = item["data"]["board"]["name"]
        "#{user} created list <a href=\"http://trello.com/board/#{board}\">#{list}</a> on #{boardname}"
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

    url = "https://trello.com/1/members/#{@@config["admin_user"]}/boards?" \
          "key=#{@@config['key']}&" \
          "token=#{@@config['token']}"

    begin
      boards = ActiveSupport::JSON.decode(open(url).read)
    rescue
      puts "could not retrieve #{url}"
      return {:messages => [], :options => {}}
    end

    boards = boards.map {|board| board["id"]}

    boards.each do |board|
      url = "https://trello.com/1/boards/#{board}/actions?" \
            "key=#{@@config['key']}&" \
            "token=#{@@config['token']}&" \
            "limit=10&" \
            "since=#{since_time}"

      begin
        items = ActiveSupport::JSON.decode(open(url).read)
      rescue
        puts "could not retrieve #{url}"
        return {:messages => [], :options => {}}
      end

      items.reverse.each do |item|
        item_time = Time.parse(item["date"])

        message = self.process_item(item)
        self.api_send(message) if !message.empty?

        if item_time > max_item_time
          max_item_time = item_time
        end
      end
    end

    Linkbot.db.execute("delete from trello")
    Linkbot.db.execute("insert into trello (dt) VALUES (?)", max_item_time)

    {:messages => messages, :options => {:room => @@config['room']}}
  end
end
