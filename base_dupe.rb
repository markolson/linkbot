require 'db'

class Linkbot
  def self.check_dupe(user, url)
    
    messages = []
    rows = Linkbot.db.execute("select user_id, url from links where url = '#{url}'")
    if rows.empty?
      Linkbot.db.execute("insert into links (user_id, dt, url) VALUES ('#{user['id']}', '#{Time.now.getgm.to_i}', '#{url}')")
    else
      Linkbot::Plugin.plugins.each {|k,v|
        if(v[:ptr].respond_to?(:on_dupe))
          p "sending duplicate link to #{k}"
          messages << v[:ptr].on_dupe(user,url)
        end
      }
    end
  end
  
  if Linkbot.db.table_info('links').empty?
    db.execute('CREATE TABLE links (user_id INTEGER, dt DATETIME, url TEXT)');
  end
  if Linkbot.db.table_info('stats').empty?
    Linkbot.db.execute('CREATE TABLE stats (user_id INTEGER, dupes INTEGER, total INTEGER)');
  end
end