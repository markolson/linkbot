# Inspired by bikeshed.io Bikeshedding-as-a-Service,
# this plugin retrieves a color badge (color name, swatch and votes)
# from colorlovers.com

class Bikeshed < Linkbot::Plugin

  require 'nokogiri'
  require 'open-uri'

  Linkbot::Plugin.register('bikeshed', self, {
    :message => {:regex => /\A!bikeshed\z/i, :handler => :on_message}
  })

  def self.on_message(message, matches)
    color = Nokogiri::XML(open('http://www.colourlovers.com/api/colors/random'))
    color.xpath('//badgeUrl').children.first.content
  end


end

