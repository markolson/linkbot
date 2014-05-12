require 'rubygems'
require 'sqlite3'

module Linkbot
  def self.db
    @@db ||= SQLite3::Database.new('data.sqlite3')
    @@db.type_translation = true
    @@db.busy_timeout(1000)
  end
  
  def self.load_users
    rows = Linkbot.db.execute("select user_id, username from users")
    @@user_ids = Hash[rows]
    @@users = Hash[rows.collect {|a,b| [b,a]}]
  end
  
  def self.users
    @@users
  end
  
  def self.user_ids
    @@user_ids
  end
  
  def self.user_exists?(user)
    rows = Linkbot.db.execute("select * from users where username = '#{user.gsub("'","\\'")}'")
    if rows.empty?
      rows = Linkbot.db.execute("select * from users where user_id = '#{user.gsub("'","\\'")}'")
      !rows.empty?
    else
      true
    end
  end
  
  def self.username(user_id)
    Linkbot.db.execute("select username from users where user_id = '#{user_id.gsub("'","\\'")}'")[0][0]
  end
  
  def self.user_id(username)
    Linkbot.db.execute("select user_id from users where username = '#{username.gsub("'","\\'")}'")[0][0]
  end
  
  # Update a username based on the user_id
  def self.update_user(username,user_id) 
    Linkbot.db.execute("update users set username = '#{username.gsub("'","\\'")}' where user_id = '#{user_id.gsub("'","\\'")}'")
  end
  
  def self.add_user(username,user_id=nil)
    rows = Linkbot.db.execute("select * from users where username = '#{username.gsub("'","\\'")}'")
    if rows.empty?
      if user_id == nil
        rows = Linkbot.db.execute("select max(user_id) from users")
        user_id = rows[0][0] + 1
      end
      Linkbot.db.execute("insert into users (user_id,username) values ('#{user_id.gsub("'","\\'")}', '#{username.gsub("'","\\'")}')")
      @@user_ids[user_id] = username
      @@users[username] = user_id
    #if we didn't find the user's id, but we found their name, update their id
    elsif user_id
      Linkbot.db.execute("update users set user_id='#{user_id.gsub("'","\\'")}' where username='#{username.gsub("'","\\'")}'")
    end
  end
  

end
