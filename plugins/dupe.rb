require 'open-uri'
require 'hpricot'
require 'sqlite3'

class Dupe < Linkbot::Plugin
  def self.regex
    /^$/
  end
  Linkbot::Plugin.register('dupe', self.regex, self)
  
  def self.on_dupe(user, message)
    r = Linkbot.db.execute("select dupes from stats where user_id='#{user['id']}'")
    if r.length > 0
      Linkbot.db.execute("update stats set dupes=#{r[0][0] + 1} where user_id='#{user['id']}'")
    else
      Linkbot.db.execute("insert into stats (user_id,total,dupes) VALUES ('#{user['id']}',0,1)")
    end
    return ['DUPE!']
  end
end