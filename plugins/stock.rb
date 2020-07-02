# encoding: UTF-8
require 'stock_quote'
class Stock < Linkbot::Plugin

  def initialize
    @config = Linkbot::Config["plugins"]["stock"]

    if @config && @config['enabled']
      if @config['iex_api_key']
        register :regex => Regexp.new('\$(\w+)')
        help "$<ticker> returns that stock's price"
      else
        Linkbot.log.warn "Stock plugin requires an API key to IEX https://iexcloud.io/cloud-login#/register/."
      end
    end
  end

  def on_message(message, matches)
    ticker = matches[0]
    StockQuote::Stock.new(api_key: @config['iex_api_key'])
    stock = StockQuote::Stock.quote(ticker)

    return [] unless stock.response_code == 200

    price = stock.bid
    name =  stock.name
    movement = stock.change
    pct = stock.change_percent_change
    upordown = movement < 0 ? '↓' : '↑'
    movetext = "#{upordown} #{movement.abs} #{pct}"

    msg = "#{name} #{price} #{movetext}"

    [msg]
  end

end
