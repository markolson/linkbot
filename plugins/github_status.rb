require 'json'
require 'open-uri'

class GithubStatus < Linkbot::Plugin
  @@hipchat = Linkbot::Config["plugins"]["hipchat"]

  Linkbot::Plugin.register('github_status', self, {
   :message => { :regex => /\A!hubstat/, :handler => :on_message, :help => :help }
  })

  def self.help
    '!hubstat - see whether your trouble with GitHub is just you'
  end

  def self.on_message(message, matches)
    response = open('https://status.github.com/api/last-message.json').read
    last_message = JSON.parse(response)
    GithubStatus.new(last_message).notify
  end

  attr_reader :api_response

  def initialize(api_response)
    @api_response = api_response
  end

  def notify
    hipchat_send("As of #{timestamp}, GitHub is <a href='https://status.github.com/'>reporting</a>: #{notice}")
  end

  private

  def timestamp
    api_response['created_on']
  end

  def notice
    api_response['body']
  end

  def color
    case api_response['status']
    when 'good'
      'green'
    when 'minor'
      'yellow'
    when 'major'
      'red'
    else
      'gray'
    end
  end

  def hipchat_send(message)
    message = CGI.escape(message)

    url = "https://api.hipchat.com/v1/rooms/message?" \
        + "auth_token=#{@@hipchat['api_token']}&" \
        + "message=#{message}&" \
        + "color=#{color}&" \
        + "room_id=#{@@hipchat['room']}&" \
        + "from=GitHub+Status"

    puts "sending message to hipchat url #{url}"
    open(url)
  rescue => e
    puts e.inspect
    puts e.backtrace.join("\n")
  end

end
