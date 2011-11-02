class ThinConnector < Linkbot::Connector
  Linkbot::Connector.register('thin', self)

  def initialize(options)
    super(options)
    listen
  end
  
  def call(env)
    if env["REQUEST_URI"] != "/message"
      [404, {'Content-Type'=>'text/plain'}, StringIO.new("404: Not found\n")]
    elsif env["REQUEST_METHOD"] != "POST"
      [405, {'Content-Type'=>'text/plain'}, StringIO.new("Only POSTs are allowed\n")]
    else
      begin
        data = JSON.parse(env["rack.input"].read)
        if data["message"].nil? || data["username"].nil?
          raise Exception.new("Invalid data")
        end
        
        if !Linkbot.user_exists?(data['username'])
          Linkbot.add_user(data['username'])
        end
        
        message = Message.new( data["message"], Linkbot.users[data['username']], data['username'], self, :message )
        process_message(message)
        
        [202, {'Content-Type'=>'text/plain'}, StringIO.new("Message accepted\n")]
      rescue Exception
        puts $!.message
        [422, {'Content-Type'=>'text/plain'}, StringIO.new("Data was in an invalid format\n")]
      end
    end
  end
  
  def listen
    Thin::Server.start('0.0.0.0', @options["port"], self)
  end

end