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
    @rooms = @options["rooms"]
    @conference = @options["conference"]
    @mucs = {}
    @connection = nil

    listen
  end
  
  def update_users
    puts "Retrieving roster..."
    @roster.get_roster
    @roster.wait_for_roster
    
    @roster.items.values.each do |roster_item|
      user_id = roster_item.jid.node
      if !Linkbot.user_exists?(user_id)
        Linkbot.add_user(roster_item.iname,user_id)
      else
        Linkbot.update_user(roster_item.iname,user_id)
      end
    end
    
  end
  

  def listen
    puts "Attempting to login..."
    @connection = ::Jabber::Client.new(Jabber::JID.new("#{@username}@#{@server}/#{@resource}"))
    @connection.connect
    puts "Authenticating..."
    @connection.auth(@password)
    
    @roster = Jabber::Roster::Helper.new(@connection)
    @roster.wait_for_roster
  
    @connection.send(::Jabber::Presence.new.set_type(:available))

    update_users
    
    puts "Adding callbacks..."

    @connection.add_message_callback do |m|
      begin
        if m.type.to_s == "chat" && m.body
          user_id = m.from.node
          if !Linkbot.user_exists?(user_id)
            update_users
          end
          nick = Linkbot.username(user_id)
          if nick != @options["fullname"]
            process_message(Time.now,nick,m.body,{:user => m.from})
          end
        end
      rescue
        puts $!.message
      end
    end

    @rooms.each do |room|
      muc = ::Jabber::MUC::SimpleMUCClient.new(@connection)
  
      muc.add_message_callback do |m|
        begin
          room = m.from.node
          nick = m.from.resource
          if nick != @options["fullname"]
            process_message(Time.now,nick,m.body,{:room => room})
          end
        rescue
          puts $!.message
        end
      end
      
      muc.join("#{room}@#{@conference}/#{@fullname}")
      @mucs[room] = muc
    end
  end
  
  def process_message(time, nick, text, options={})
    # Attempt to get the user from the roster
    
    if !Linkbot.user_exists?(nick)
      update_users
    end
    
    if Linkbot.user_exists?(nick)
      message = Message.new( text, Linkbot.user_id(nick), nick, self, :message, options )  
      invoke_callbacks(message, options)
    end
  end
  
  def send_messages(messages, options={})
    messages.each do |message|
      if message && message.strip.length > 0
        if options[:room] && @mucs[options[:room]]
          @mucs[options[:room]].send(::Jabber::Message.new(nil,message),nil)
        
          # I don't like this, but hipchat has problems receiving a lot of messages at once in-order and keeping them in order.
          sleep(1.0/10.0)
        elsif options[:user]
          msg = ::Jabber::Message.new(options[:user],message)
          msg.type = :chat
          @connection.send(msg)
        
          # I don't like this, but hipchat has problems receiving a lot of messages at once in-order and keeping them in order.
          sleep(1.0/25.0)
        end
      end
    end
  end
end
