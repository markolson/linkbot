require 'rubygems'
require 'json'
require 'pp'

class PullRequests < Linkbot::Plugin
  @@config = Linkbot::Config["plugins"]["pull_requests"]
  if @@config
    include HTTParty
    base_uri @config["base_uri"]
    basic_auth @config["username"], @config["password"]
    debug_output $stderr
  end

  def initialize
    @config = @@config

    if @config
      if Linkbot.db.table_info('pull_requests').empty?
        Linkbot.db.execute('CREATE TABLE pull_requests (number INTEGER)');
      end

      register :periodic => {:handler => :periodic}
    end
  end

  def periodic()
    min_pull = 0
    rows = Linkbot.db.execute("select max(number) from pull_requests")
    min_pull = rows[0][0].to_i if !rows.empty?

    res = get("/repos/#{@config["owner"]}/#{@config["project"]}/pulls")
    response = res.body
    JSON.load(response)
    if res.code >= 200 && res.code < 300
      messages = []
      response.each do |pullreq|
        next if pullreq["number"].to_i <= min_pull
        messages << "New pull request:\n#{pullreq['title']}\n#{pullreq['body']}\n#{pullreq['url']}"
        Linkbot.db.execute("insert into pull_requests (number) VALUES (?)", pullreq["number"])
      end

      {:messages => messages, :options => {:room => @config[:room]}}
    else
      puts "Login error"
    end
  end
end
