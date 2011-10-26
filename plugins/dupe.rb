require 'open-uri'
require 'hpricot'
require 'sqlite3'
require 'time'

class Dupe < Linkbot::Plugin
  
  Linkbot::Plugin.register('dupe', self,
    {
      :message => {:regex => /!stats/, :handler => :on_message, :help => :help}
    }
  )
  
  def self.on_message(message, matches) 
    rows = Linkbot.db.execute("select u.username,s.total,s.dupes,k.karma,u.showname from stats s, users u, karma k where u.user_id = s.user_id AND u.user_id = k.user_id order by k.karma desc")
    mess = "Link stats:\n--------------------------\n"

    #find the maximum length karma total
    max = rows.collect { |row| row[1].to_s }.map(&:length).max

    rows.each {|row|
      username = (row[4].nil? || row[4] == '') ? row[0] : row[4]
      dupe = row[2] == 1 ? 'dupe' : 'dupes'
      mess = mess + sprintf("%#{max}d: #{username} (%d links, %d %s, %.2f%% new)\n", row[3], row[1], row[2], dupe, (row[1]/(row[1]+row[2]).to_f)*100)
    }
    mess
  end
  
  def self.on_dupe(message, url, duped_user, duped_timestamp)
    total,dupes = self.stats(message.user_id)
    Linkbot.db.execute("update stats set dupes = #{dupes+1} where user_id='#{message.user_id}'")
    res = Linkbot.db.execute("select username,showname from users where user_id='#{message.user_id}'")[0]
    username = (res[1].nil? || res[1] == '') ? res[0] : res[1]
    puts duped_timestamp
    "DUPE: Previously posted by #{duped_user} #{::Util.ago_in_words(Time.now, Time.parse(duped_timestamp.to_s))}"
  end
  
  def self.on_newlink(message, url)
    total,dupes = self.stats(message.user_id)
    Linkbot.db.execute("update stats set total = #{total+1} where user_id='#{message.user_id}'")
  end
  
  
  def self.stats(user_id)
    total = 0
    dupes = 0
    rows = Linkbot.db.execute("select user_id,total,dupes from stats where user_id = '#{user_id}'")
    if rows.empty?
      Linkbot.db.execute("insert into stats (user_id,total,dupes) values ('#{user_id}', 0, 0)")
    else
      total = rows[0][1]
      dupes = rows[0][2]
    end
    return total,dupes
  end
  
  def self.help
    "!stats - show all karma and links stats for linkchat participants"
  end
  
  if Linkbot.db.table_info('stats').empty?
    Linkbot.db.execute('CREATE TABLE stats (user_id INTEGER, dupes INTEGER, total INTEGER)');
  end
end
