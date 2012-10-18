require 'octokit'

class Github < Linkbot::Plugin
  @@config  = Linkbot::Config["plugins"]["github"]
  @@hipchat = Linkbot::Config["plugins"]["hipchat"]

  if @@config
    Linkbot::Plugin.register('github', self, {
      :message => {:regex => /!hub (\w+)(.*)/, :handler => :on_message, :help => :help}
    })
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
      return ["error: no repository specified. !hub pull <repo> to show pull requests for <repo>"]
    end
    puts "getting pull requests for repo #{args}"

    pull_reqs = client.pull_requests("Lookingglass/#{args[0]}")
    pull_reqs.sort! { |req| req.number.to_i }
    msg = pull_reqs.map{ |req| "#{req.number}: <a href=\"#{req.html_url}\">#{req.title}</a>" }
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
    stale = client.branches(repo).map do |branch|
      abranch = client.branch("Lookingglass/scoutvision", branch.name)

      #crazily, this appears to be the simplest way to get the date
      [abranch.commit.commit.committer.date, abranch.name, abranch._links.html]
    end
    stale.sort!
    msg = stale[0..5].map{ |dt, name, link| "<a href=\"#{link}\">#{name}</a> #{dt}" }
    self.hipchat_send msg.join("<br>"), "hub"
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
    elsif command.start_with? "help"
      return [%{!hub pull <repo> - show open pull requests for repository <repo>
!hub repos - show all Lookingglass repos
!hub stale <repo> - show stale branches in repo}]
    end

    []
  end

  def self.help
    "!hub <command> <args> - interact with github. Use the help command for more."
  end
end
