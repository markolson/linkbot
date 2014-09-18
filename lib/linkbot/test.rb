load "linkbot.rb"

class TestConsole
   
  def initialize
    @user_id = 0
    @user_name = "UserName"
    @type = MessageType::MESSAGE
    @connector = "debug"
    puts "Commands - !!set  - set message vars"
    puts "         - !!show - show message vars" 
    puts "         - !!exit" 
  end
  
  def set_message
    puts "\nHit enter to skip.\n\n"
    puts "Message Type: (currently '#{@type}') (options: #{MessageType.constants.join(',')})"
    set_var(@type, gets.chomp)
    puts "Message User ID: (currently '#{@user_id}')"
    set_var(@user_id, gets.chomp)
    puts "Message User Name: (currently '#{@user_name}')"
    set_var(@user_name, gets.chomp)
    puts "\n"
    true
  end

  def set_var(var, input)
    var.replace input if !input.empty?
  end

  def show_message
    puts "\n"
    puts "Type: #{@type}"
    puts "User ID: #{@user_id}"
    puts "User Name: #{@user_name}"
    puts "\n"
    true
  end

  def send_body
    puts "Input:"
    msg = gets.chomp
    if !check_commands(msg)
      message = Message.new(msg, @user_id, @user_name, @connector, @type, {})
      puts Linkbot::Plugin.handle_message(message)
    end
    send_body
  end

  def check_commands(msg)
    case msg
    when "!!set"
      set_message
    when "!!show"
      show_message
    when "!!exit"
      abort("Vaya con Dios.")
    else
      false
    end
      
  end
end

app = TestConsole.new()
Linkbot::Plugin.collect
app.send_body
