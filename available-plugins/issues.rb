require 'rubygems'
require 'json'
require 'httparty'
require 'pp'

class Issues < Linkbot::Plugin

  @@config = Linkbot::Config["plugins"]["activecollab"]

  if @@config
    include HTTParty
    base_uri @@config["url"]
    debug_output $stderr

    Linkbot::Plugin.register('issues', self, {
      :message => {:regex => Regexp.new('!issue (.*)'),
                   :handler => :on_message, :help => :help
      }
    })
  end

  def self.issue_search(needle)
    res = get("/projects/1/tickets?format=json&token=#{@@config['token']}")
    issues = JSON.load(res.body)

    issues_found = []

    issues.each do |issue|
      haystack = issue["name"] + issue["body"]

      if haystack.match /#{needle}/i
        issues_found << issue
      end
    end

    issues_found
  end

  def self.on_message(message, matches)
    query = matches[0]

    msg = []

    issues = self.issue_search(query)
    for issue in issues
      msg << "#{issue['permalink']}: #{issue['name']}"
    end

    #self.api_send(msg)
    msg
  end

  def self.help
    "!issue <query> - search for open issues that match your query"
  end
end
