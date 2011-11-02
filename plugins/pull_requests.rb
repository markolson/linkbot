require 'rubygems'
require 'json'
require 'httparty'
require 'pp'
require 'config.rb'

class PullRequests < Linkbot::Plugin
  include HTTParty
  base_uri "https://api.github.com"
  basic_auth GITHUB_USER, GITHUB_PASS
  debug_output $stderr
  @@pulls = []

  Linkbot::Plugin.register('pullrequest', self,
    {
      :periodic => {:handler => :periodic},
    }
  )

  def self.periodic()
    puts "here"
    response = JSON.load(get("/repos/Lookingglass/scoutvision/pulls").body)
    messages = []
    response.each do |pullreq|
      next if @@pulls.index pullreq["number"]

      messages << "New pull request:\n#{pullreq['title']}\n#{pullreq['body']}\n#{pullreq['url']}"
      @@pulls << pullreq["number"]
    end
    pp "returning #{messages.join '\n'}"
    messages.join "\n"
  end

end
