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

    def self.handle(message)

      log(:global, message)
      log("_room_#{message[:options][:room]}", message)
      log("_user_#{message[:options][:user]}", message)

      final_message = []

      Linkbot::Plugin.plugins.each {|k,plugin|
        next unless plugin[:ptr].has_permission?(message)
        next unless plugin[:ptr].has_handler_for?(message)

        # TODO: Typecheck that :regex is a regex.
        if matches = (plugin[:handlers][message.type][:regex].nil? || plugin[:handlers][message.type][:regex].match(message.body))

          matches = matches.to_a.drop(1)
          begin
            output_messages = plugin[:ptr].send(plugin[:handlers][message.type][:handler], message, matches)
            next if output_messages.empty?

            final_message.concat(Array(output_messages))
          rescue => e
            output_messages = "the #{k} plugin threw an exception: #{e.inspect}"
            puts e.inspect
            puts e.backtrace.join("\n")
          end
        end
      }
      final_message
    end

    def self.message_history(message)
      if message[:options][:room]
        @@message_logs["_room_#{message[:options][:room]}"]
      elsif message[:options][:user]
        @@message_logs["_user_#{message[:options][:user]}"]
      else
        @@message_logs[:global]
      end
    end

    def self.create_log(log_name)
      @@message_logs[log_name] ||= []
    end

    def self.log(log_name, message)
      create_log(log_name)

      if @@message_logs[log_name].length >= 100
        @@message_logs[log_name].pop
      end
      @@message_logs[log_name].unshift(message)
    end

  end
end
