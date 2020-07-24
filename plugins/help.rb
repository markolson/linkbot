class Helper < Linkbot::Plugin

  def initialize
    register :regex => /!help/
  end

  def on_message(message, matches)
    messages = []
    Linkbot::Plugin.plugins.each {|plugin|
      if( !plugin.help.nil? &&
          plugin.handlers &&
          plugin.handlers[message.type] )

        begin
          messages << plugin.help
        rescue => e
          Linkbot.log.error "Helper plugin #{e.inspect}"
          Linkbot.log.error e.backtrace.join("\n")
        end
      end
    }
    messages.sort! do |x,y|
      x =~ /([A-Za-z]+)/
      sort1 = $1
      y =~ /([A-Za-z]+)/
      sort2 = $1
      sort1 <=> sort2
    end
    messages.join("\n")
  end
end
