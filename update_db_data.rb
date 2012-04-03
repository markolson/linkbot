require 'rubygems'
require 'sqlite3'

db = SQLite3::Database.new('data.sqlite3')
db.type_translation = true

data = db.execute("SELECT user_id,username FROM users")

data.each do |user|
  user_id = user[0]
  username = user[1]
  
  # Update each table
  db.execute("UPDATE karma SET user_id='#{user_id}' WHERE user_id='#{username}'")
  db.execute("UPDATE links SET user_id='#{user_id}' WHERE user_id='#{username}'")
  db.execute("UPDATE stats SET user_id='#{user_id}' WHERE user_id='#{username}'")
  db.execute("UPDATE trans SET user_id='#{user_id}' WHERE user_id='#{username}'")
  db.execute("UPDATE users SET user_id='#{user_id}' WHERE user_id='#{username}'")
end