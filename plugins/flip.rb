class Flip < Linkbot::Plugin
  Linkbot::Plugin.register('jason', self,
    {
      :message => {:regex => Regexp.new('!flip(?: (\d+)|([\w\s,]+))?'), :handler => :on_message, :help => :help},
      :"direct-message" => {:regex => Regexp.new('!flip(?: (\d+)|([\w\s,]+))?'), :handler => :on_message, :help => :help}
    }
  )
  
  def self.on_message(message, matches) 
    if not matches
      return rand(2) == 0 ? "heads" : "tails"
    elsif matches[0].match /\d+/
      return (1..matches[0].to_i).map { rand(2) == 0 ? "heads" : "tails" }
    else
      return matches[0].split(',').sort_by { rand }
    end
  end
  
  def self.help
    "!flip [n] [john, steve, randy] - flip a coin n times or shuffle a comma separated list"
  end
end
