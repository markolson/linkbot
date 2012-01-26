require 'xmpp4r'
require 'xmpp4r/roster/helper/roster'
require 'xmpp4r/muc/helper/simplemucclient'

class JabberConnector < Linkbot::Connector
  Linkbot::Connector.register('jabber', self)

  def initialize(options)
    super(options)
        
    @fullname = @options["fullname"] ? @options["fullname"] : @options["username"]
    @username = @options["username"]
    @password = @options["password"]
    @resource = @options["resource"]
    @server = @options["server"]
    @room = @options["room"]
    @conference = @options["conference"]
    @muc = nil
    @connection = nil
    
    @start_time = Time.now.to_i
    
    listen
  end


  def listen
    puts "Attempting to login..."
    @connection = ::Jabber::Client.new(Jabber::JID.new("#{@username}@#{@server}/#{@resource}"))
    @connection.connect
    puts "Authenticating..."
    @connection.auth(@password)
    @connection.send(::Jabber::Presence.new.set_type(:available))
    
    @muc = ::Jabber::MUC::SimpleMUCClient.new(@connection)
    
    @muc.on_message do |time,nick,text|
      begin
        if Time.now.to_i - @start_time > 3 && nick != @options["fullname"]
          process_message(time,nick,text)
        end
      rescue
        puts $!.message
      end
    end
    
    @muc.join("#{@room}@#{@conference}/#{@fullname}")
  end
  
  
  
  def process_message(time,nick,text)
    # Attempt to get the user from the roster
    
    if !Linkbot.user_exists?(nick)
      Linkbot.add_user(nick,nick)
    end
    
    message = Message.new( text, nick, nick, self, :message )
    invoke_callbacks(message)
  end
  
  

  def send_messages(messages)
    final_messages = []
    messages.each {|m| final_messages = final_messages + m.split("\n")}
    
    final_messages.each do |message|
      if message && message.strip.length > 0
        @muc.send(::Jabber::Message.new(nil,message),nil)
        
        # I don't like this, but hipchat has problems receiving a lot of messages at once in-order and keeping them in order.
        sleep(1.0/25.0)
      end
    end
  end
end
