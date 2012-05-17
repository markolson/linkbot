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

  def self.api_send(message)
    puts "message is:"
    pp message
    message = CGI.escape(message)
    color = @@config['color'] || "purple"
    from = @@config['from'] || "activecollab"
    puts " requesting https://api.hipchat.com/v1/rooms/message?" \
        +"auth_token=#{@@config['hipchat_api_token']}&" \
        +"message=#{message}&" \
        +"color=#{color}&" \
        +"room_id=#{@@config['room']}&" \
        +"from=#{from}"
    begin
      open("https://api.hipchat.com/v1/rooms/message?" \
          +"auth_token=#{@@config['hipchat_api_token']}&" \
          +"message=#{message}&" \
          +"color=#{color}&" \
          +"room_id=#{@@config['room']}&" \
          +"from=#{from}")
    rescue => e
      puts e.inspect
      puts e.backtrace.join("\n")
    end
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

    #while issues.length > 0
    #  for issue in issues
    #    haystack = issue["subject"] + issue["description"]
    #    if issue.has_key? "assigned_to"
    #      haystack += issue["assigned_to"]["name"]
    #    end

    #    if haystack.match /#{needle}/i
    #      issues_found << issue
    #    end
    #  end
    #  offset += limit
    #  res = get("/issues.json?offset=#{offset}&limit=#{limit}")
    #  issues = JSON.load(res.body)["issues"]
    #end

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

    time_link = "track time: http://redmine.corp.lgscout.com/issues/#{issue['id']}/time_entries/new"
    issue_link = "issue link: http://redmine.corp.lgscout.com/issues/#{issue['id']}"

    return [
      issue_link,
      time_link,
    "#{issue['id']}: #{issue['subject']}\n#{issue['description']}\nstatus: #{issue['status']['name']}"
    ]
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
        msg += "<a href=\"#{issue['permalink']}\">#{issue['ticket_id']}</a>: #{issue['name']}<br>"
      end
    end

    self.api_send(msg)
    ""
  end

  def self.help
    "!issue <query> - search for open issues that match your query"
  end
end
