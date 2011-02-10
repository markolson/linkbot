require 'rubygems'
require 'sqlite3'

class Linkbot
  def self.db
    @@db ||= SQLite3::Database.new('data.sqlite3')
  end
end