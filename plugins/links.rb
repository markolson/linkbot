class Linkbot
  class Dupe    
    Linkbot::Plugin.register('links', self,
      {
        :message => {:regex => Regexp.new('(?i)\b((?:[a-z][\w-]+:(?:/{1,3}|[a-z0-9%])|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:\'".,<>?«»“”‘’]))'), 
                    :handler => :on_message}
      }
    )
  
    def self.on_message(text, matches, msg)
      url = matches[0]
      
      messages = []
      rows = Linkbot.db.execute("select user_id,dt from links where url = '#{url}'")
      if rows.empty?
        Linkbot::Plugin.plugins.each {|k,v|
          messages << v[:ptr].on_newlink(user,url).join("\n") if(v[:ptr].respond_to?(:on_newlink)) 
        }
        # Add the link to the dupe table
        Linkbot.db.execute("insert into links (user_id, dt, url) VALUES ('#{user['id']}', '#{Time.now.getgm.to_i}', '#{url}')")
      else
        Linkbot::Plugin.plugins.each {|k,v|
          messages << v[:ptr].on_dupe(user,url,rows[0][0],rows[0][1]).join("\n") if(v[:ptr].respond_to?(:on_dupe)) 
        }
      end  
      messages.join("\n")
    end
  
    if Linkbot.db.table_info('users').empty?
      Linkbot.db.execute('CREATE TABLE users (user_id INTEGER, username TEXT, showname TEXT)')
    end
    if Linkbot.db.table_info('links').empty?
      Linkbot.db.execute('CREATE TABLE links (user_id INTEGER, dt DATETIME, url TEXT)');
    end

    if Linkbot.db.table_info('trans').empty?
      Linkbot.db.execute('CREATE TABLE trans (user_id INTEGER, karma INTEGER, trans TEXT)');
    end
    
  end
end
