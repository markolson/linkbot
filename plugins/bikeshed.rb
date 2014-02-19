# Inspired by bikeshed.io Bikeshedding-as-a-Service,
# this plugin retrieves a colour badge (colour name, swatch and votes)
# from colourlovers.com

class Bikeshed < Linkbot::Plugin
  require 'nokogiri'
  require 'open-uri'

  Linkbot::Plugin.register('bikeshed', self, {
    :message => {:regex => /\A!bikeshed\z/i, :handler => :on_message}
  })

  def self.on_message(message, matches)
    colour = Nokogiri::XML(open('http://www.colourlovers.com/api/colors/random'))
    colour.css("badgeUrl").children.first.content
  end
end

