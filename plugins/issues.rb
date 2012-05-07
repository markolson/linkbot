require 'rubygems'
require 'json'
require 'httparty'
require 'pp'

class Issues < Linkbot::Plugin

  @@config = Linkbot::Config["plugins"]["redmine"]

  if @@config
    include HTTParty
    base_uri @@config["url"]
    basic_auth @@config["user"], @@config["pass"]
    debug_output $stderr

    Linkbot::Plugin.register('issues', self, {
      :message => {:regex => Regexp.new('!issue (.*)'),
                   :handler => :on_message, :help => :help
      }
    })
  end

  def self.issue_search(needle)
    offset = 0
    limit = 100
    res = get("/issues.json?offset=#{offset}&limit=#{limit}&status_id=open")
    issues = JSON.load(res.body)["issues"]
    pp issues.length, limit

    issues_found = []

    while issues.length > 0
      puts "----------- #{offset} #{limit}"
      for issue in issues
        if (issue["subject"] + issue["description"]).match /#{needle}/i
          issues_found << issue
        end
      end
      offset += limit
      res = get("/issues.json?offset=#{offset}&limit=#{limit}")
      issues = JSON.load(res.body)["issues"]
    end

    issues_found
  end

  def self.on_message(message, matches)
    issues = self.issue_search(matches[0])

    msg = ""
    for issue in issues
      msg += "#{issue["id"]}: #{issue["subject"]}\n"
    end

    msg
  end

  def self.help
    "!issue <query> - search for open issues that match your query"
  end
end
