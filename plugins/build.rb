require 'net/http'
require 'uri'
require 'json'

class Build < Linkbot::Plugin

  def initialize
    register :regex => /\A!build (.+) (.+)/
    help "!build <repo> <ref> - Build a specific tag or branch for the given repository"
    @config = Linkbot::Config["plugins"].fetch("build", {})
    @webhook = @config.fetch("webhook", false)
  end

  def on_message(message, matches)
    project = matches[0]
    ref = matches[1]

    unless @webhook
      return "The build plugin must be configured for use"
    end

    uri = URI.parse("#{@webhook}/#{project}/#{ref}")
    res = JSON.parse(Net::HTTP.get_response(uri).body)
    if res["status"] == 'ok'
      "Attempting to start build of #{project}/#{ref}..."
    else
      "Uh oh! A build problem occurred: #{res["error"]}"
    end
  end

end
