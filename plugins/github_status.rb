require 'json'
require 'open-uri'

class Hubstat < Linkbot::Plugin
  @@hipchat = Linkbot::Config["plugins"]["hipchat"]

  Linkbot::Plugin.register('hubstat', self, {
   :message => { :regex => /\A!hubstat/, :handler => :on_message, :help => :help }
  })

  def self.help
    '!hubstat - see whether your trouble with GitHub is just you'
  end

  def self.on_message(message, matches)
    response = open('https://status.github.com/api/last-message.json').read
    last_message = JSON.parse(response)
    status = GithubStatus.new( last_message['status'],
                               last_message['body'],
                               last_message['created_on'] )
    hipchat_send( status.color, status.message )
  end

  GithubStatus = Struct.new(:status, :body, :created_on) do
    def color
      case self.status
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

    def message
      "As of #{self.created_on}, GitHub is <a href='https://status.github.com/'>reporting</a>: #{self.body}"
    end
  end

  def self.hipchat_send(color, message)
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
