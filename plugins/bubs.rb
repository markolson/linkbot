# encoding: utf-8

class Bubs < Linkbot::Plugin
  def initialize
    register :regex => /!bubs (.*)/
  end

  def on_message(message, matches)
    matches[0].tr('A-Za-z1-90', 'Ⓐ-Ⓩⓐ-ⓩ①-⑨⓪')
  end

end
