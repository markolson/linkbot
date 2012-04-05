require 'rubygems'
require 'sqlite3'

module Linkbot
  def self.db
    @@db ||= SQLite3::Database.new('data.sqlite3')
    @@db.type_translation = true
    @@db
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
    rows = Linkbot.db.execute("select * from users where username = '#{user}'")
    if rows.empty?
      rows = Linkbot.db.execute("select * from users where user_id = '#{user}'")
      !rows.empty?
    else
      true
    end
  end
  
  def self.username(user_id)
    Linkbot.db.execute("select username from users where user_id = '#{user_id}'")[0][0]
  end
  
  def self.user_id(username)
    Linkbot.db.execute("select user_id from users where username = '#{username}'")[0][0]
  end
  
  # Update a username based on the user_id
  def self.update_user(username,user_id) 
    Linkbot.db.execute("update users set username = '#{username}' where user_id = '#{user_id}'")
  end
  
  def self.add_user(username,user_id=nil)
    rows = Linkbot.db.execute("select * from users where username = '#{username}'")
    if rows.empty?
      if user_id == nil
        rows = Linkbot.db.execute("select max(user_id) from users")
        user_id = rows[0][0] + 1
      end
      Linkbot.db.execute("insert into users (user_id,username) values ('#{user_id}', '#{username}')")
      @@user_ids[user_id] = username
      @@users[username] = user_id
    end
  end
  

end
