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

  def self.on_message(message, matches)
    command = matches[0]
    args = matches[1]
    client = Octokit::Client.new(:login => @@config['username'], :password => @@config['password'])

    if command == "pull"
      pull_reqs = client.pull_requests("Lookingglass/scoutvision")
      pull_reqs.sort! { |req| req.number.to_i }
      msg = pull_reqs.map{ |req| "#{req.number}: <a href=\"#{req.html_url}\">#{req.title}</a>" }
      self.hipchat_send msg.join("<br>"), "hub"
    end

    return []
  end

  def self.help
    "!hub <command> <args> - interact with github"
  end
end
