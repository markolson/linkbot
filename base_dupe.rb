require 'db'

class Linkbot
  def self.regexp
    Regexp.new('(?i)\b((?:[a-z][\w-]+:(?:/{1,3}|[a-z0-9%])|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:\'".,<>?«»“”‘’]))')
  end
  
  def self.check_dupe(user, url)
    return unless url =~ self.regexp
    
    messages = []
    rows = Linkbot.db.execute("select user_id, url from links where url = '#{url}'")
    if rows.empty?
      Linkbot::Plugin.plugins.each {|k,v|
        messages << v[:ptr].on_newlink(user,url).join("\n") if(v[:ptr].respond_to?(:on_newlink)) 
      }
      Linkbot.db.execute("insert into links (user_id, dt, url) VALUES ('#{user['id']}', '#{Time.now.getgm.to_i}', '#{url}')")
    else
      Linkbot::Plugin.plugins.each {|k,v|
        messages << v[:ptr].on_dupe(user,url).join("\n") if(v[:ptr].respond_to?(:on_dupe)) 
      }
    end  
      s = messages.join("\n")
      print "\n----\n" + s + "\n---\n" if s.length > 1
  end
  
  if Linkbot.db.table_info('links').empty?
    db.execute('CREATE TABLE links (user_id INTEGER, dt DATETIME, url TEXT)');
  end
  if Linkbot.db.table_info('stats').empty?
    Linkbot.db.execute('CREATE TABLE stats (user_id INTEGER, dupes INTEGER, total INTEGER)');
  end
end