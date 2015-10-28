# encoding: UTF-8
class Stock < Linkbot::Plugin

  def initialize
    register :regex => Regexp.new('\$(\w+)')
    help "$<ticker> returns that stock's price"
  end

  def on_message(message, matches)
    ticker = matches[0]
    doc = Hpricot(open("http://www.google.com/ig/api?stock=#{ticker}"))
    price = (doc/"last").first.attributes["data"]
    name =  (doc/"company").first.attributes["data"]

    return [] if name.empty?

    movement = (doc/"change").first.attributes["data"].to_f
    pct = (doc/"perc_change").first.attributes["data"].to_f
    upordown = movement < 0 ? '↓' : '↑'
    movetext = "#{upordown} #{movement.abs} #{pct}%"

    msg = "#{name} #{price} #{movetext}"

    [msg]
  end

end
