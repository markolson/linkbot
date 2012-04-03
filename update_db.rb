require 'rubygems'
require 'sqlite3'

db = SQLite3::Database.new('data.sqlite3')
db.type_translation = true

db.execute("ALTER TABLE karma RENAME TO karma_tmp")
db.execute("ALTER TABLE links RENAME TO links_tmp")
db.execute("ALTER TABLE stats RENAME TO stats_tmp")
db.execute("ALTER TABLE trans RENAME TO trans_tmp")
db.execute("ALTER TABLE users RENAME TO users_tmp")

db.execute("CREATE TABLE karma (user_id STRING, karma INTEGER);")
db.execute("CREATE TABLE links (user_id STRING, dt DATETIME, url TEXT);")
db.execute("CREATE TABLE stats (user_id STRING, dupes INTEGER, total INTEGER);")
db.execute("CREATE TABLE trans (user_id STRING, karma INTEGER, trans TEXT);")
db.execute("CREATE TABLE users (user_id STRING, username TEXT, showname TEXT);")

db.execute("INSERT INTO karma SELECT * FROM karma_tmp")
db.execute("INSERT INTO links SELECT * FROM links_tmp")
db.execute("INSERT INTO stats SELECT * FROM stats_tmp")
db.execute("INSERT INTO trans SELECT * FROM trans_tmp")
db.execute("INSERT INTO users SELECT * FROM users_tmp")

db.execute("DROP TABLE karma_tmp")
db.execute("DROP TABLE links_tmp")
db.execute("DROP TABLE stats_tmp")
db.execute("DROP TABLE trans_tmp")
db.execute("DROP TABLE users_tmp")