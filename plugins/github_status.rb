require 'json'
require 'open-uri'

class Hubstat < Linkbot::Plugin
  @@config = Linkbot::Config["plugins"]["hubstat"]
  @@hipchat = Linkbot::Config["plugins"]["hipchat"]

  if @@config
    Linkbot::Plugin.register('hubstat', self, {
     :message => { :regex => /\A!hubstat/, :handler => :on_message, :help => :help }
    })
  end

  def self.help
    '!hubstat - see whether your trouble with GitHub is just you'
  end

  def self.on_message(message, matches)
    response = JSON.parse(open('https://status.github.com/api/last-message.json').read)

    colors = {
      "good" => "green",
      "minor" => "yellow",
      "major" => "red"
    }
    color = colors.fetch(response['status'], "gray")

    message = "As of #{response["created_on"]}, GitHub is <a href='https://status.github.com/'>reporting</a>: #{response["body"]}"
    hipchat_send(color, message)
  end

  def self.hipchat_send(color, message)
    message = CGI.escape(message)
    room = @@config['room'] || @@hipchat['room']

    url = "https://api.hipchat.com/v1/rooms/message?" \
        + "auth_token=#{@@hipchat['api_token']}&" \
        + "message=#{message}&" \
        + "color=#{color}&" \
        + "room_id=#{room}&" \
        + "from=GitHub+Status"

    puts "sending message to hipchat url #{url}"
    open(url)
  rescue => e
    puts e.inspect
    puts e.backtrace.join("\n")
  end

end
