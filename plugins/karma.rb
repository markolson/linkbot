class Karma < Linkbot::Plugin
  def initialize
    register :regex => //
    if Linkbot.db.table_info('karma').empty?
      Linkbot.db.execute('CREATE TABLE karma (user_id INTEGER, karma INTEGER)');
    end
  end

  def on_newlink(message, url)
    karma = self.get_karma(message.user_id)
    Linkbot.db.execute("update karma set karma=? where user_id=?", karma+1, message.user_id)
  end

  def on_dupe(message, url, duped_user, duped_timestamp)
    karma = self.get_karma(message.user_id)
    Linkbot.db.execute("update karma set karma=? where user_id=?", karma-5, message.user_id)
    "Removed 5 karma"
  end

  def get_karma(user_id)
    karma = 0
    # Create the user's info, if it does not exist
    rows = Linkbot.db.execute("select * from users where user_id=?", user_id)
    if rows.empty?
      #linkbot should ensure creating a user... bail out here if it hasn't
      raise "could not find user #{user_id}"
    end

    rows = Linkbot.db.execute("select user_id,karma from karma where user_id=?", user_id)
    if rows.empty?
      Linkbot.db.execute("insert into karma (user_id,karma) values (?, 0)", user_id)
    else
      karma = rows[0][1]
    end
    return karma
  end

end
