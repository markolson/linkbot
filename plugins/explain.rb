class Explain < Linkbot::Plugin

    register :regex => /!explain(?: (.+))?/i

    def self.on_message(message, matches)
      cmd = CGI.escape(matches[0])
      "http://explainshell.com/explain?cmd=#{cmd}"
    end
end
