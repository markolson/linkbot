module Linkbot
  class PeriodMessager
   def self.handle
      final_messages = []

      Linkbot::Plugin.plugins.each {|plugin|
        if plugin.handlers[:periodic] && plugin.handlers[:periodic][:handler]

          puts "#{plugin.name} processing periodic message"
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
            puts e.inspect
            puts e.backtrace.join("\n")
          end
        end
      }

      if final_messages.length
        puts "returning msgs from periodic plugins:"
        pp final_messages
      end
      final_messages
    end
  end
end
