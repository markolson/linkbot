require 'octokit'

class Github < Linkbot::Plugin
  @@config  = Linkbot::Config["plugins"]["github"]
  @@hipchat = Linkbot::Config["plugins"]["hipchat"]

  if @@config
    Linkbot::Plugin.register('github', self, {
      :message => {:regex => /!gh (\w+) (.*)/, :handler => :on_message, :help => help}
    })
  end

  def self.hipchat_send(message)
    return if message.empty?

    pp message
    message = CGI.escape(message)
    color = @@config['hipchat_color'] || "purple"
    from = @@config['hipchat_from'] || "Trello"
    begin
      url = "https://api.hipchat.com/v1/rooms/message?" \
          + "auth_token=#{@@config['hipchat_api_token']}&" \
          + "message=#{message}&" \
          + "color=#{color}&" \
          + "room_id=#{@@config['hipchat_room']}&" \
          + "from=#{from}"

      puts "sending message to hipchat url #{url}"
      open(url)
    rescue => e
      puts e.inspect
      puts e.backtrace.join("\n")
    end
  end

  def self.on_message(message, matches)
    command = matches[1]
    args = matches[2..-1].split " "
    client = Octokit::Client.new(:login => @@config['username'], :password => @@config['password'])

    if command == "pull"
      pull_reqs = client.pull_requests("Lookingglass/scoutvision")
      pull_reqs.each |req| do
        self.hipchat_send "#{req.number}: <a href=\"#{req.url}\">#{req.title}</a>"
      end
    end
  end

  def self.help
    "!github <command> <args> - interact with github"
  end
end
