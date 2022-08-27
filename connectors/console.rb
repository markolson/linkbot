module Linkbot
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

      EventMachine::defer(proc {
        invoke_callbacks(message, options)
      })
      EventMachine::defer(proc { prompt})
    end

    def send_messages(msgs, options={})
      msgs.each do |msg|
        puts msg
      end
      EventMachine::defer(proc { prompt})
    end
  end
end
