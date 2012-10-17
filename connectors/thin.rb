class ThinConnector < Linkbot::Connector
  Linkbot::Connector.register('thin', self)

  def initialize(options)
    super(options)
    listen
  end
  
  def call(env)
    puts env.to_json
    case env["REQUEST_URI"]
    when "/message"
      if env["REQUEST_METHOD"] != "POST"
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

          message = Message.new( data["message"], Linkbot.users[data['username']], data['username'], self, :message, {} )
          invoke_callbacks(message)

          [202, {'Content-Type'=>'text/plain'}, StringIO.new("Message accepted\n")]
        rescue Exception
          puts $!.message
          [422, {'Content-Type'=>'text/plain'}, StringIO.new("Data was in an invalid format\n")]
        end
      end
    when "/"
      data = <<-EOF
      <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
      <html xmlns="http://www.w3.org/1999/xhtml">
        <head>
          <title>My Google API Application</title>
          <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.6.4/jquery.min.js" type="text/javascript"></script>
          <script language="Javascript" type="text/javascript">
            function sendMessage() {
              var data = {
                message: $('#message').val(),
                username: "Anonymous"
              };
              
              var dataString = JSON.stringify(data);
              
              $.ajax({
                type: 'POST',
                url: '/message',
                contentType: 'application/json',
                data: dataString,
                beforeSend: function(xhr) {
                  $("#submit").html("Sending...");
                  $("#message").val("");
                },
                error: function(obj,status) {
                  $("#submit").html("Send");
                },
                success: function() {
                  $("#submit").html("Send");
                }
              })
            }
          </script>
        </head>
        <body>
          GIMME A MESSAGE:<br/>
          <input type="text" id="message" style="width: 400px;" />
          <button type="button" id="submit" onclick="sendMessage();">Send</button>
        </body>
      </html>
      EOF
      [200, {'Content-Type'=>'text/html'}, StringIO.new(data)]
    else
      [404, {'Content-Type'=>'text/plain'}, StringIO.new("404: Not found\n")]
    end
  end
  
  def listen
    Thin::Server.start('0.0.0.0', @options["port"], self)
  end

end