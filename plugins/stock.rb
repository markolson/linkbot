# encoding: UTF-8
class Stock < Linkbot::Plugin

  Linkbot::Plugin.register('stock', self, {
    :message => {:regex => Regexp.new('\$(\w+)'), :handler => :on_message, :help => :help},
    :"direct-message" => {:regex => Regexp.new('\$(\w)+'), :handler => :on_message, :help => :help}
  })

  def self.on_message(message, matches)
    ticker = matches[0]
    doc = Hpricot(open("http://finance.yahoo.com/q?s=#{ticker}&ql=1"))
    price = (doc/".time_rtq_ticker").text
    name =  (doc/".title h2").text

    movement = (doc/".time_rtq_content")
    wentdown = !!movement.first.attributes["class"].match(/down/)
    upordown = wentdown ? '↓' : '↑'
    diff     = movement.text.strip.sub /\(/, " ("
    movetext = "#{upordown} #{diff}"

    msg = "#{name} #{price} #{movetext}"

    if !msg.strip.empty?
      [msg]
    else
      []
    end
  end

  def self.help
    "$<ticker> returns that stock's price"
  end
end
