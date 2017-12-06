require "logger"
require "em/pure_ruby"
require "em-irc"

class IRCConnector < Linkbot::Connector
  Linkbot::Connector.register('irc', self)

  def initialize(options)
    super(options)

    @nick     = options["nick"]
    @fullname = options["fullname"]
    @username = options["username"]
    @host     = options["server"]
    @port     = options["port"] || "6667"
    @rooms    = options["rooms"]
  end

  def start
    host = @host
    port = @port
    rooms = @rooms
    nick = @nick
    rooms = @rooms
    parent = self

    @client = EventMachine::IRC::Client.new do
      host host
      port port

      on :connect do
        Linkbot.log.info "IRC connector: connected to #{host}:#{port}, setting nick #{nick}"
        nick nick
        rooms.each do |room|
          Linkbot.log.info "IRC connector: connecting to #{room}"
          join room
        end
      end

      on :join do |channel|
        Linkbot.log.info "IRC connector: joined #{channel}"
      end

      on :message do |user, room, message|
        if !room.start_with? "#"
          room = user
        end

        parent.handle_message(user, room, message)
        Linkbot.log.debug "IRC connector: <#{user}> -> <#{room}>: #{message}"
      end
    end

    @client.run!  # start EventMachine loop
  end

  def handle_message(nick, room, msg)
    options = {room: room}

    if !Linkbot.user_exists?(nick)
      Linkbot.add_user(nick, nick)
    end

    message = Message.new(msg, Linkbot.user_id(nick), nick, self, :message, options)
    invoke_callbacks(message, options)
  end

  def send_messages(msgs, options={})
    Linkbot.log.debug "IRC connector: got messages #{msgs} <<#{options}>>"
    msgs.each do |msg|
      if msg && msg.strip.length > 0 && options[:room]
        msg.split("\n").each do |line|
          @client.message(options[:room], line)
        end
      end
    end
  end
end
