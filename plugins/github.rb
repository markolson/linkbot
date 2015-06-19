require 'date'
require 'octokit'

class Github < Linkbot::Plugin
  @@config  = Linkbot::Config["plugins"]["github"]
  @@hipchat = Linkbot::Config["plugins"]["hipchat"]

  help "!hub <command> <args> - interact with github. Use the help command for more."

  if @@config && @@hipchat
    register :regex => /!hub (\w+)(.*)/
  end

  def self.hipchat_send(message, from)
    return if message.empty?

    pp message
    message = CGI.escape(message)
    color = @@hipchat['color'] || "purple"
    begin
      url = "https://api.hipchat.com/v1/rooms/message?" \
          + "auth_token=#{@@hipchat['api_token']}&" \
          + "message=#{message}&" \
          + "color=#{color}&" \
          + "room_id=#{@@hipchat['room']}&" \
          + "from=#{from}"

      puts "sending message to hipchat url #{url}"
      open(url)
    rescue => e
      puts e.inspect
      puts e.backtrace.join("\n")
    end
  end

  def self.get_pull_requests(client, command, args)
    if args.empty?
      repos = client.org_repos(@@config["organization"]).map{|x| x.name}
    else
      repos = [args[0]]
    end

    msg = []
    repos.each do |repo|
      pull_reqs = client.pull_requests("Lookingglass/#{repo}")
      pull_reqs.sort! { |req| req.number.to_i }
      if pull_reqs.length > 0
        msg += ["<b>#{repo}</b>"]
        msg += pull_reqs.map{ |req| "#{req.number}: <a href=\"#{req.html_url}\">#{req.title}</a> by #{req.user.login}" }
      end
    end
    self.hipchat_send msg.join("<br>"), "hub"
    []
  end

  def self.get_repos(client, command, args)
    repolinks = client.org_repos(@@config["organization"]).map {|x| "<a href=\"#{x.html_url}\">#{x.name}</a>" }
    self.hipchat_send repolinks.join("<br>"), "hub"
    []
  end

  def self.get_stale_branches(client, command, args)
    repo = "#{@@config['organization']}/#{args[0]}"
    branches_info = client.branches(repo).map do |branch|
      abranch = client.branch("Lookingglass/scoutvision", branch.name)
      most_recent = abranch.commit.commit
      days_old = (Date.today-Date.parse(most_recent.committer.date)).to_i

      [days_old, abranch.name, most_recent.author.name, abranch._links.html]
    end

    stale_branches = branches_info.select{ |x| x[0] > 90 }
    stale_branches.sort!.reverse!

k    msg = stale_branches.map{ |days, name, author, link| "#{days} days old: <a href=\"#{link}\">#{name}</a> last commit: #{author}" }

    if msg.length > 0
      self.hipchat_send msg.join("<br>"), "hub"
      []
    else
      ["no stale branches found for repo <#{args[0]}>"]
    end
  end

  def self.get_issues(client, command, args)
    if not args.length > 0
      return ["Missing query. To search for an issue, use: !hub issue <query>"]
    end
    query = args[0]
    repos = client.org_repos(@@config["organization"]).map{|x| x.name}

    msg = []
    repos.each do |repo|
      issues = client.search_issues("#{@@config["organization"]}/#{repo}", query)
      if issues.length > 0
        msg += ["<b>#{repo}</b>"]
        msg += issues.map{|issue| "#{issue.number}: <a href=\"#{issue.html_url}\">#{issue.title}</a>"}
      end
    end

    if msg.length > 0
      self.hipchat_send msg.join("<br>"), "hub"
      []
    else
      ["no issues found for query <#{query}>"]
    end
  end

  def self.search(client, command, args)
    if not args.length > 0
      return ["Missing query. To search for code use: !hub search <query>"]
    end
    query = args.join " "

    res = client.search_code "@#{@@config["organization"]} #{query}", :accept => "application/vnd.github.preview.text-match+json"

    msg = res.items[0..9].map do |item|
      url = item.rels[:html].href_template.to_s
      filename = url.match(/blob\/.*?\/(.*)/)[1]

      link = "<a href=\"#{url}\">#{item.repository.name}:#{filename}</a>"

      # this is how to get text fragments, but they're too large and annoying
      # ... I really wish github provided line numbers to me, but they don't
      # ATM. I have filed a support request, but until then, I'm killing this
      #fragments = item.text_matches.map { |m| m.fragment }.join("<br>")
      #fraghtml = "<pre>#{fragments}</pre>"

      #"#{link}<br>#{fraghtml}"
    end

    search_url = "https://github.com/search?q=%40lookingglass%20#{URI.escape(query)}&type=Code&ref=searchresults"

    msg.insert(0, "<a href=\"#{search_url}\">#{res.total_count} results</a>")

    if msg.length > 0
      self.hipchat_send msg.join("<br>"), "hub"
      []
    else
      ["no issues found for query <#{query}>"]
    end
  end

  def self.on_message(message, matches)
    command = matches[0]
    args = matches[1].split " "
    puts command, args
    client = Octokit::Client.new(:login => @@config['username'], :password => @@config['password'])

    if command.start_with? "pull"
      return self.get_pull_requests(client, command, args)
    elsif command.start_with? "repos"
      return self.get_repos(client, command, args)
    elsif command.start_with? "stale"
      return self.get_stale_branches(client, command, args)
    elsif command.start_with? "issue"
      return self.get_issues(client, command, args)
    elsif command.start_with? "search"
      return self.search(client, command, args)
    else
      return [%{!hub pull [<repo>] - show open pull requests for repository <repo> or all repos if omitted
!hub repos - show all Lookingglass repos
!hub stale <repo> - show stale branches in repo
!hub search <query> - search lg code for <query>
!hub issue <query> - search for issues}]
    end

    []
  end

end
