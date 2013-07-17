require 'json'
require 'open-uri'
require 'active_support/time'

class Hubstat < Linkbot::Plugin
  @@config = Linkbot::Config["plugins"]["hubstat"]
  @@hipchat = Linkbot::Config["plugins"]["hipchat"]

  if @@config && @@hipchat
    Linkbot::Plugin.register('hubstat', self, {
     :message => { :regex => /\A!hubstat/, :handler => :on_message, :help => :help },
     :periodic => {:handler => :periodic}
    })
  end

  if Linkbot.db.table_info('hubstatus').empty?
    Linkbot.db.execute('CREATE TABLE hubstatus (dt TEXT)');
  end

  def self.help
    '!hubstat - see whether your trouble with GitHub is just you'
  end

  def self.post_status(response)
    colors = {
      "good" => "green",
      "minor" => "yellow",
      "major" => "red"
    }
    color = colors.fetch(response['status'], "gray")

    timestr = message_time.in_time_zone("EST").strftime("%b %d %H:%m EST")

    message = "As of #{timestr}, GitHub is <a href='https://status.github.com/'>reporting</a>: #{response["body"]}"
    hipchat_send(color, message)
  end

  def self.periodic
    #by default, post the message if it's within the last day
    last_pulled = Time.now.utc - 60*60*24

    rows = Linkbot.db.execute("select dt from hubstatus")
    last_pulled = Time.parse(rows[0][0]) if !rows.empty? && rows[0][0]

    response = self.get_status

    #don't print the message if time exists and is newer than the message
    status_time = Time.parse(response["created_on"])
    if last_pulled && last_pulled < status_time
      self.post_status(response)
    end

    Linkbot.db.execute("delete from hubstatus")
    Linkbot.db.execute("insert into hubstatus (dt) VALUES ('#{status_time.to_s}')")
    {:messages => []}
  end

  def self.on_message(message, matches)
    response = self.get_status
    self.post_status(response)
    []
  end

  def self.get_status
    JSON.parse(open('https://status.github.com/api/last-message.json').read)
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
