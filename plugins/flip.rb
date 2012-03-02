class Flip < Linkbot::Plugin
  Linkbot::Plugin.register('flip', self,
    {
      :message => {:regex => Regexp.new('!flip(?: (\d+)|([\d\w\s,]+))?'), :handler => :on_message, :help => :help},
      :"direct-message" => {:regex => Regexp.new('!flip(?: (\d+)|([\w\s,]+))?'), :handler => :on_message, :help => :help}
    }
  )

  def self.on_message(message, matches) 
    if !matches || matches == [nil, nil]
      return rand(2) == 0 ? "heads" : "tails"
    elsif matches[0] && matches[0].match(/\d+/)
      return (1..matches[0].to_i).map { rand(2) == 0 ? "heads" : "tails" }.join ", "
    else
      return matches[1].split(',').sort_by { rand }.map { |x| x.strip }.join ", "
    end
  end
  
  def self.help
    "!flip [n] [john, steve, randy] - flip a coin n times or shuffle a comma separated list"
  end
end
