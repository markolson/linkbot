class Helper < Linkbot::Plugin

  register :regex => /!help/

  def self.on_message(message, matches)
    messages = []
    Linkbot::Plugin.plugins.each {|k,v|
      if(v[:handlers][message.type] && v[:ptr].respond_to?(:help) && !v[:ptr].help.nil?)
        begin
          messages << v[:ptr].help
        rescue => e
          puts e.inspect
          puts e.backtrace.join("\n")
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
