class Colors < Linkbot::Plugin

  ESC = "\033"

  COLORS = {
    "black" => "30m",
    "red" => "31m",
    "green" => "32m",
    "yellow" => "33m",
    "blue" => "34m",
    "magenta" => "35m",
    "cyan" => "36m",
    "white" => "39m"
    }

  def self.on_message(message, matches)
    color, text = self.parse_color_and_text_from message.body
    colorize(color, text)
  end

  def self.parse_color_and_text_from msg
    msg.scan(/^#{self.colors_regex} (.*)/)[0]
  end

  def self.colorize color, text
    "#{ESC}[#{COLORS[color]}#{text}#{ESC}[#{COLORS['white']}"
  end

  def self.colors_regex
    "(#{COLORS.keys.join('|')})"
  end

  Linkbot::Plugin.register('colors', self, {
    :message => {:regex => /^#{self.colors_regex}/, :handler => :on_message}
  })
end
