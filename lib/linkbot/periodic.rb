module Linkbot
  class PeriodMessager
   def self.handle
      final_messages = []

      Linkbot::Plugin.plugins.each {|plugin|
        if plugin.handlers[:periodic] && plugin.handlers[:periodic][:handler]

          Linkbot.log.debug "#{plugin.name} processing periodic message"
          begin
            #messages should be a hash {:messages => [<message:string>],
            #                           :options => {"room": <room:string>}
            #                          }
            messages = plugin.send(plugin.handlers[:periodic][:handler])

            if !messages[:messages].empty?
              final_messages << messages
            end
          rescue Exception => e
            final_messages << "the #{plugin.name} plugin threw an exception: #{e.inspect}"
            Linkbot.log.error "Periodic Handler: #{e.inspect}"
            Linkbot.log.error e.backtrace.join("\n")
          end
        end
      }

      if final_messages.length
        Linkbot.log.debug "Periodic Handler: returning msgs from periodic plugins"
        Linkbot.log.debug final_messages.join("\n")
      end
      final_messages
    end
  end
end
