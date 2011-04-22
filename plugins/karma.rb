class Karma < Linkbot::Plugin
  def self.regex
    /!karma/
  end
  Linkbot::Plugin.register('karma', self.regex, self)
  
  def self.on_message(user, message, matches)  
    rows = Linkbot.db.execute("select u.username,k.karma from karma k, users u where u.user_id = k.user_id order by k.karma desc")
    mess = "Link karma:\n--------------------------\n"
    max = 1
    divvy = 10
    rows.each do |row|
      while true do
        if row[1].to_i / divvy > 0
          max = max + 1
          divvy = divvy * 10
        else
          break
        end
      end
    end
    rows.each {|row| mess = mess + sprintf("%#{max}d: #{row[0]}\n", row[1])}
    [mess]
  end
  
  def self.on_starred(user, starred_user, starred_message)
    karma = self.get_karma(starred_user)
    msg = ""
    if user['id'] == starred_user['id']
      Linkbot.db.execute("update karma set karma = #{karma - 5} where user_id = '#{starred_user['id']}'")
      msg = "You can't vote for yourself. Lose 5 karma."
    else
      Linkbot.db.execute("update karma set karma = #{karma + 5} where user_id = '#{starred_user['id']}'")
      starred_username = Linkbot.db.execute("select username from users where user_id = '#{starred_user['id']}'")[0][0]
      username = Linkbot.db.execute("select username from users where user_id = '#{user['id']}'")[0][0]
      msg = "5 karma added to #{starred_username} by #{username} (star)"
    end
    [msg]
  end
  
  def self.on_unstarred(user, starred_user, starred_message)
    karma = self.get_karma(starred_user)
    msg = ""
    if user['id'] == starred_user['id']
      Linkbot.db.execute("update karma set karma = #{karma - 10} where user_id = '#{starred_user['id']}'")
      msg = "That was even more stupid. Lose 10 karma."
    else
      Linkbot.db.execute("update karma set karma = #{karma - 5} where user_id = '#{starred_user['id']}'")
      starred_username = Linkbot.db.execute("select username from users where user_id = '#{starred_user['id']}'")[0][0]
      username = Linkbot.db.execute("select username from users where user_id = '#{user['id']}'")[0][0]
      msg = "5 karma removed from #{starred_username} by #{username} (unstar)"
    end
    [msg]
  end
  
  def self.on_newlink(user, message)
    karma = self.get_karma(user)
    Linkbot.db.execute("update karma set karma = #{karma + 1} where user_id = '#{user['id']}'")
  end
  
  def self.on_dupe(user, message, duped_user, duped_timestamp)
    karma = self.get_karma(user)
    Linkbot.db.execute("update karma set karma = #{karma - 5} where user_id = '#{user['id']}'")
    ["Removed 5 karma"]
  end
  
  def self.get_karma(user)
    karma = 0
    # Create the user's info, if it does not exist
    rows = Linkbot.db.execute("select * from users where user_id = '#{user['id']}'")
    if rows.empty?
      Linkbot.db.execute("insert into users (user_id,username) values ('#{user['id']}', '#{user['username']}')")
    end
    rows = Linkbot.db.execute("select user_id,karma from karma where user_id = '#{user['id']}'")
    if rows.empty?
      Linkbot.db.execute("insert into karma (user_id,karma) values ('#{user['id']}', 0)")
    else
      karma = rows[0][1]
    end
    return karma
  end
  
  if Linkbot.db.table_info('karma').empty?
    Linkbot.db.execute('CREATE TABLE karma (user_id INTEGER, karma INTEGER)');
  end
end