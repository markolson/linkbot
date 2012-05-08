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

    issues_found = []

    while issues.length > 0
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

  def self.get_details(issue_number)
    begin
      res = get("http://redmine.corp.lgscout.com/issues/#{issue_number}.json")
      issue = JSON.load(res.body)
    rescue
      #probably invalid permissions. issuebot only has access to some tickets.
      return "unable to load issue #{issue_number}"
    end

    if !issue.has_key? "issue"
      return "issue #{issue_number} not found"
    end
    issue = issue["issue"]

    time_link = "http://redmine.corp.lgscout.com/issues/#{issue['id']}/time_entries/new"

    "#{issue['id']}: #{issue['subject']}\n#{issue['description']}\nstatus: #{issue['status']['name']}\n\nLog time: #{time_link}"
  end

  def self.on_message(message, matches)
    query = matches[0]

    msg = ""

    #if query's a number, print details on the issue
    if query.match /^\d+$/
      msg = self.get_details(query)
    else
      issues = self.issue_search(query)
      for issue in issues
        msg += "#{issue['id']}: #{issue['subject']}\n"
      end
    end

    msg
  end

  def self.help
    "!issue <query> - search for open issues that match your query"
  end
end
