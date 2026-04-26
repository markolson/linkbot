# Inspired by bikeshed.io Bikeshedding-as-a-Service,
# this plugin retrieves a colour badge (colour name, swatch and votes)
# from colourlovers.com

class Bikeshed < Linkbot::Plugin
  require 'json'

  def initialize
    register :regex => /\A!bikeshed\z/i
  end

  def on_message(message, matches)
    hex = '%06x' % rand(0xffffff)
    colour = JSON.parse(http_get("https://www.thecolorapi.com/id?hex=#{hex}&format=json"))
    "#{colour['name']['value']} (##{hex.upcase})"
  end
end
