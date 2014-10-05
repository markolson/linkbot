class MessageType
  MESSAGE       = :message
  DIRECTMESSAGE = :"direct-message"
  STARRED       = :starred
  UNSTARRED     = :unstarred
end

Message = Struct.new(:body, :user_id, :user_name, :connector, :type, :options)
Response = Struct.new(:message, :options)

module Linkbot
  class Message
    @@message_logs = {}
    @@message_logs[:global] = []

    def self.handle(message)
      @@message_logs[:global] << message

      # Check for a room-wide message
      if message[:options][:room]
        @@message_logs[message[:options][:room]] ||= []
        @@message_logs[message[:options][:room]] << message
      end

      # Check for a user-specific message
      if message[:options][:user]
         @@message_logs[message[:options][:user]] ||= []
         @@message_logs[message[:options][:user]] << message
      end

      final_message = []

      Linkbot::Plugin.plugins.each {|k,v|
        if v[:ptr].has_permission?(message) && v[:handlers][message.type] && v[:handlers][message.type][:handler]

          if ((v[:handlers][message.type][:regex] && v[:handlers][message.type][:regex].match(message.body)) || v[:handlers][message.type][:regex].nil?)

            matches = v[:handlers][message.type][:regex] ? v[:handlers][message.type][:regex].match(message.body).to_a.drop(1) : nil

            begin
              end_msg = v[:ptr].send(v[:handlers][message.type][:handler], message, matches)

              if !end_msg.empty?
                if end_msg.is_a? Array
                  final_message.concat(end_msg)
                else
                  final_message << end_msg
                end
              end
            rescue => e
              end_msg = "the #{k} plugin threw an exception: #{e.inspect}"
              puts e.inspect
              puts e.backtrace.join("\n")
            end
          end
        end
      }
      final_message
    end

    def self.message_history(message)
      if message[:options][:room]
        @@message_logs[message[:options][:room]]
      elsif message[:options][:user]
        @@message_logs[message[:options][:user]]
      else
        @@message_logs[:global]
      end
    end

    def self.create_log(log_name)
      @@message_logs[log_name] ||= []
    end

    def self.log(log_name, message)
      if @@message_logs[log_name].length >= 100
        @@message_logs[log_name].pop
      end
      @@message_logs[log_name].unshift(message)
    end

    def self.registered_methods
      @registered_methods ||= {}
      @registered_methods
    end
  end

end
