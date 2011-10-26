class Karma < Linkbot::Plugin
  Linkbot::Plugin.register('karma', self,
    {
      :star => {:handler => :on_starred},
      :unstar => {:handler => :on_unstarred}
    }
  )
  
  #TODO
  #def self.on_starred(message, matches)
  #  starred_user = msg['star']['message']['user']
  #  starred_message = msg['star']['message']['message']
  #  karma = self.get_karma(starred_user)
  #  msg = ""
  #  if user['id'] == starred_user['id']
  #    Linkbot.db.execute("update karma set karma = #{karma - 5} where user_id = '#{starred_user['id']}'")
  #    msg = "You can't vote for yourself. Lose 5 karma."
  #  else
  #    Linkbot.db.execute("update karma set karma = #{karma + 5} where user_id = '#{starred_user['id']}'")
  #    starred_username = Linkbot.db.execute("select username from users where user_id = '#{starred_user['id']}'")[0][0]
  #    username = Linkbot.db.execute("select username from users where user_id = '#{user['id']}'")[0][0]
  #  end
  #  msg
  #end
  
  #TODO
  #def self.on_unstarred(text, matches)
  #  starred_user = msg['star']['message']['user']
  #  starred_message = msg['star']['message']['message']
  #  karma = self.get_karma(starred_user)
  #  msg = ""
  #  if user['id'] == starred_user['id']
  #    Linkbot.db.execute("update karma set karma = #{karma - 20} where user_id = '#{starred_user['id']}'")
  #    msg = "That was incredibly stupid. Lose 20 karma."
  #  else
  #    Linkbot.db.execute("update karma set karma = #{karma - 5} where user_id = '#{starred_user['id']}'")
  #    starred_username = Linkbot.db.execute("select username from users where user_id = '#{starred_user['id']}'")[0][0]
  #    username = Linkbot.db.execute("select username from users where user_id = '#{user['id']}'")[0][0]
  #  end
  #  msg
  #end
  
  def self.on_newlink(message, url)
    karma = self.get_karma(message.user_id)
    Linkbot.db.execute("update karma set karma = #{karma + 1} where user_id = '#{message.user_id}'")
  end
  
  def self.on_dupe(message, url, duped_user, duped_timestamp)
    karma = self.get_karma(message.user_id)
    Linkbot.db.execute("update karma set karma = #{karma - 5} where user_id = '#{message.user_id}'")
    "Removed 5 karma"
  end
  
  def self.get_karma(user_id)
    karma = 0
    # Create the user's info, if it does not exist
    rows = Linkbot.db.execute("select * from users where user_id = '#{user_id}'")
    if rows.empty?
      #linkbot should ensure creating a user... bail out here if it hasn't
      raise "could not find user #{user_id}"
    end

    rows = Linkbot.db.execute("select user_id,karma from karma where user_id = '#{user_id}'")
    if rows.empty?
      Linkbot.db.execute("insert into karma (user_id,karma) values ('#{user_id}', 0)")
    else
      karma = rows[0][1]
    end
    return karma
  end
  
  if Linkbot.db.table_info('karma').empty?
    Linkbot.db.execute('CREATE TABLE karma (user_id INTEGER, karma INTEGER)');
  end
end
