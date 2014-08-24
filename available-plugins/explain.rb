class Explain < Linkbot::Plugin
    Linkbot::Plugin.register('explain', self,
      {
        :message => {:regex => /!explain(?: (.+))?/i, :handler => :on_message}
      }
    )

    def self.on_message(message, matches)
      cmd = CGI.escape(matches[0])
      "http://explainshell.com/explain?cmd=#{cmd}"
    end
end
