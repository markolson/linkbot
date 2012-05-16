require 'rubygems'
require 'json'
require 'httparty'
require 'pp'
require 'time'

class ActiveCollab < Linkbot::Plugin

  @@config = Linkbot::Config["plugins"]["activecollab"]

  if @@config
    Linkbot::Plugin.register('activecollab', self, {
      :periodic => {:handler => :periodic}
    })
  end

  def self.periodic
    #by default, grab all entries since one day ago
    min_pull = Time.now - 60*60*24
    rows = Linkbot.db.execute("select max(dt) from activecollab")
    min_pull = Time.parse(rows[0][0]) if !rows.empty? && rows[0][0]

    messages = []

    max_item_time = min_pull
    
    doc = Hpricot(open("#{@@config['url']}/rss?token=#{@@config['token']}"))
    doc.search("item").each do |item|
      item_time = Time.parse((item/"pubdate").text)
      next if item_time <= min_pull

      messages << (item/"title").text
      #unclear why item/"link" doesn't parse properly? Using guid instead.
      messages << (item/"guid").text

      if item_time > max_item_time
        max_item_time = item_time
      end
    end

    Linkbot.db.execute("insert into activecollab (dt) VALUES ('#{max_item_time}')")

    messages
  end

  if @@config
    if Linkbot.db.table_info('activecollab').empty?
      Linkbot.db.execute('CREATE TABLE activecollab (dt TEXT)');
    end
  end
end
