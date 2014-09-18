class Console < Linkbot::Connector
  Linkbot::Connector.register('console', self)

  def initialize(options)
    super(options)
  end

  def start
    prompt
  end

  def prompt
    print "[Console] >> "
    handle_message(gets)
  end

  def handle_message(nick='Terminal User', room='Console', msg)
    options = {room: room}

    if !Linkbot.user_exists?(nick)
      Linkbot.add_user(nick, nick)
    end

    message = Message.new(msg, Linkbot.user_id(nick), nick, self, :message, options)
    invoke_callbacks(message, options)
  end

  def send_messages(msgs, options={})
    msgs.each do |msg|
      msg.split("\n").each do |line|
        puts "[Linkbot] >> " + line
      end
    end
    prompt
  end
end
