require 'rubygems'
require 'json'
require 'pp'
require 'config.rb'

class PullRequests < Linkbot::Plugin
  include HTTParty
  @@config = Linkbot::Config["plugins"]["pull_requests"]
  base_uri @@config["base_uri"]
  basic_auth @@config["username"], @@config["password"]
  debug_output $stderr

  Linkbot::Plugin.register('pullrequest', self,
    {
      :periodic => {:handler => :periodic},
    }
  )

  def self.periodic()
    min_pull = 0
    rows = Linkbot.db.execute("select max(number) from pull_requests")
    min_pull = rows[0][0].to_i if !rows.empty?
    
    response = JSON.load(get("/repos/#{@@config["owner"]}/#{@@config["project"]}/pulls").body)
    messages = []
    response.each do |pullreq|
      next if pullreq["number"].to_i <= min_pull
      messages << "New pull request:\n#{pullreq['title']}\n#{pullreq['body']}\n#{pullreq['url']}"
      Linkbot.db.execute("insert into pull_requests (number) VALUES (#{pullreq["number"]})")
    end
    pp "returning #{messages.join '\n'}"
    messages.join "\n"
  end
  
  if Linkbot.db.table_info('pull_requests').empty?
    Linkbot.db.execute('CREATE TABLE pull_requests (number INTEGER)');
  end
end