require 'rubygems'
require 'time'
require 'sqlite3'

db = SQLite3::Database.new('data.sqlite3')

links_hash = {}
links = []
users = {}

# Clear the stats
db.execute("update stats set dupes=0, total=0")

# Pull the links and sort
db.execute("select dt,user_id,url from links").each do |row|
  links << {:link => row[2], :timestamp => Time.parse(row[0]).to_i, :user => row[1]}
end
links.sort!{|a,b| a[:timestamp] <=> b[:timestamp]}


links.each do |link|
  users[link[:user]] ||= {:total => 0, :dupes => 0}
  users[link[:user]][:total] = users[link[:user]][:total] + 1
  if !links_hash[link[:link]].nil?
    users[link[:user]][:dupes] = users[link[:user]][:dupes] + 1
  else
    links_hash[link[:link]] = true
  end
end

# Go through the users, update the stats
users.each do |user_id,user|
  db.execute("update stats set dupes=?, total=? where user_id=?",
             user[:dupes], user[:total], user_id)
  db.execute("update karma set karma=? where user_id=?", user[:total], user_id)
end
