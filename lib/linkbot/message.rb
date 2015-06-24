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

      final_message = []

      Linkbot::Plugin.plugins.each {|plugin|
        next unless plugin.has_permission?(message)
        next unless plugin.has_handler_for?(message)

        # TODO: Typecheck that :regex is a regex.
        if plugin.matches?(message)
          matches = plugin.matches(message)
          begin
            output_messages = plugin.send(plugin.handlers[message.type][:handler], message, matches)
            next if output_messages.empty?

            final_message.concat(Array(output_messages))
          rescue => e
            output_messages = "the #{plugin.name} plugin threw an exception: #{e.inspect}"
            puts e.inspect
            puts e.backtrace.join("\n")
          end
        end
      }
      final_message
    end

  end
end
