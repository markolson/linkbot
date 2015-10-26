class Explain < Linkbot::Plugin

  def initialize
    register :regex => /!explain(?: (.+))?/i
  end

  def on_message(message, matches)
    cmd = CGI.escape(matches[0])
    "http://explainshell.com/explain?cmd=#{cmd}"
  end
end
