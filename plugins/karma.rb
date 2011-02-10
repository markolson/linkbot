class Karma < Linkbot::Plugin
  def self.regex
    /!vote|!boo/
  end
  Linkbot::Plugin.register('karma', self.regex, self)
  
  def self.on_message(user, message, matches)  
    last_user = Linkbot.db.execute('select * from links order by dt desc limit 1')[0][0].to_i
    if(user['id'] == last_user)
      self.karma(last_user, -5)
      return ["Nooooope"]
    end
    if(message == '!vote')
      self.karma(last_user, 5)
      return ["Gave some karma for the last link"]
    elsif(message == '!boo')
      self.karma(last_user, -5)
      return ["Punished by taking some karma for the last link"]
    end
  end
  
  def self.on_newlink(user, message)
    self.karam(user['id'],1)
    []
  end
  
  def self.on_dupe(user, message)
    self.karma(user['id'],-5)
    ["Removed 5 karma"]
  end
  
  def self.karma(user_id, move)
    karma_rows = Linkbot.db.execute("select user_id,karma from karma where user_id = '#{user_id}'")
    if karma_rows.length == 0
      Linkbot.db.execute("insert into karma (user_id,karma) VALUES ('#{user_id}', #{move})")
    else
      Linkbot.db.execute("update karma set karma = #{karma_rows[0][1].to_i + move} where user_id = '#{user_id}'")
    end
  end
  
  if Linkbot.db.table_info('karma').empty?
    Linkbot.db.execute('CREATE TABLE karma (user_id INTEGER, karma INTEGER)');
  end
end