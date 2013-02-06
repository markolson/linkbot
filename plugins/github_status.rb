require 'json'
require 'open-uri'

class Hubup < Linkbot::Plugin
  Linkbot::Plugin.register('hubup', self, {
   :message => { :regex => /\A!hubup/, :handler => :on_message }
  })

  def self.on_message(message, matches)
    last_message = get_status
    "As of #{last_message['created_on']}, GitHub is <a href='https://status.github.com/'>reporting</a>: #{last_message['status'].upcase} - #{last_message['body']}"
  end

  def self.get_status
    response = open('https://status.github.com/api/last-message.json').read
    JSON.parse(response)
  end

end
