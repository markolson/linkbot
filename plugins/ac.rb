require 'rubygems'
require 'json'
require 'pp'
require 'time'
require 'cgi'

class ActiveCollab < Linkbot::Plugin

  @@config = Linkbot::Config["plugins"]["activecollab"]

  if @@config
    Linkbot::Plugin.register('activecollab', self, {
      :periodic => {:handler => :periodic}
    })
  end

  def self.api_send(message)
    puts "message is:"
    pp message
    message = CGI.escape(message)
    color = @@config['color'] || "purple"
    from = @@config['from'] || "activecollab"
    puts " requesting https://api.hipchat.com/v1/rooms/message?" \
        +"auth_token=#{@@config['hipchat_api_token']}&" \
        +"message=#{message}&" \
        +"color=#{color}&" \
        +"room_id=#{@@config['room']}&" \
        +"from=#{from}"
    begin
      open("https://api.hipchat.com/v1/rooms/message?" \
          +"auth_token=#{@@config['hipchat_api_token']}&" \
          +"message=#{message}&" \
          +"color=#{color}&" \
          +"room_id=#{@@config['room']}&" \
          +"from=#{from}")
    rescue => e
      puts e.inspect
      puts e.backtrace.join("\n")
    end
  end

  def self.periodic
    #by default, grab all entries since one day ago
    min_pull = Time.now - 60*60*24
    rows = Linkbot.db.execute("select max(dt) from activecollab")
    min_pull = Time.parse(rows[0][0]) if !rows.empty? && rows[0][0]

    messages = []

    max_item_time = min_pull
    
    doc = Hpricot(open("#{@@config['url']}/rss?token=#{@@config['token']}"))

    #never push more than 10 items
    doc.search("item").slice(0,10).each do |item|
      item_time = Time.parse((item/"pubdate").text)
      next if item_time <= min_pull

      linkurl = (item/"guid").text
      link = " <a href=\"#{linkurl}\">#{linkurl}</a>"
      self.api_send((item/"title").text + link)

      if item_time > max_item_time
        max_item_time = item_time
      end
    end

    Linkbot.db.execute("insert into activecollab (dt) VALUES ('#{max_item_time}')")

    {:messages => [], :options => {}}
    #{:messages => messages, :options => {:room => @@config['room']}}
  end

  if @@config
    if Linkbot.db.table_info('activecollab').empty?
      Linkbot.db.execute('CREATE TABLE activecollab (dt TEXT)');
    end
  end
end
